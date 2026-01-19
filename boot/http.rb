require "foobara/rack_connector"
require "foobara/entities_plumbing"
require "foobara/auth_http"
require "foobara_demo/blog_auth"

set_user_to_auth_user = Foobara::CommandConnectors::Http::SetInputToProcResult.for(:user) do
  authenticated_user.send(:auth_user)
end
set_user_to_blog_auth_user = Foobara::CommandConnectors::Http::SetInputToProcResult.for(:user) do
  blog_auth_user
end

env = ENV["FOOBARA_ENV"]
secure = env != "development" && env != "test"

login_response_mutators = [
  Foobara::AuthHttp::MoveRefreshTokenToCookie.new(secure:),
  Foobara::AuthHttp::MoveAccessTokenToHeader
]

connector_class = Foobara::CommandConnectors::Http::Rack
# TODO: we should be able to register these on an instance inside the block passed to .new
connector_class.register_allowed_rule :is_article_author, -> { blog_user == article.author }
connector_class.register_allowed_rule :is_author, -> { blog_user == author }

RACK_CONNECTOR = connector_class.new(
  authenticator: [:bearer, :api_key],
  auth_map: {
    blog_auth_user: FoobaraDemo::BlogAuth::User,
    blog_user: FoobaraDemo::BlogAuth::FindBlogUserForAuthUser
  }
) do
  # TODO: we need a reusable way to reuse allowed rules across connectors
  command FoobaraDemo::Blog::StartNewArticle, allow_if: :is_author
  command FoobaraDemo::Blog::DeleteArticle, allow_if: :is_article_author
  command FoobaraDemo::Blog::EditArticle, allow_if: :is_article_author
  command FoobaraDemo::Blog::PublishArticle, allow_if: :is_article_author
  command FoobaraDemo::Blog::PublishArticleChanges, allow_if: :is_article_author
  command FoobaraDemo::Blog::UnpublishArticle, allow_if: :is_article_author

  command FoobaraDemo::BlogAuth::Register, inputs: { only: [:username, :email, :plaintext_password] }

  # TODO: we should have a shortcut that can just return an auth_mapped value
  # TODO: don't return a bunch of stuff on the auth user like encrypted secrets
  command FoobaraDemo::BlogAuth::GetCurrentUser,
          :auth,
          :aggregate_entities,
          request: set_user_to_blog_auth_user

  command Foobara::Auth::Login,
          inputs: { only: [:username_or_email, :plaintext_password] },
          response: login_response_mutators
  command Foobara::Auth::RefreshLogin,
          request: Foobara::AuthHttp::SetRefreshTokenFromCookie,
          inputs: { only: :refresh_token },
          response: login_response_mutators
  command Foobara::Auth::Logout,
          request: Foobara::AuthHttp::SetRefreshTokenFromCookie,
          response: Foobara::AuthHttp::ClearAccessTokenHeader
  command Foobara::Auth::CreateApiKey,
          :auth,
          inputs: Foobara::AttributesTransformers.reject(:needs_approval),
          request: set_user_to_auth_user
  command Foobara::Auth::DeleteApiKey, allow_if: -> { authenticated_user.api_keys.include?(token) }
  command Foobara::Auth::GetApiKeySummaries,
          :auth,
          request: set_user_to_auth_user
end
