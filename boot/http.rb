require "foobara/rack_connector"
require "foobara/entities_plumbing"
require "foobara/auth_http"
require "foobara_demo/blog_auth"

env = ENV["FOOBARA_ENV"]
secure = env != "development" && env != "test"

connector_class = Foobara::CommandConnectors::Http::Rack
# TODO: we should be able to register these on an instance inside the block passed to .new
connector_class.register_allowed_rule :is_article_author, -> { blog_user == article.author }
connector_class.register_allowed_rule :is_author, -> { blog_user == author }

auth_map = {
  blog_auth_user: FoobaraDemo::BlogAuth::User,
  blog_user: FoobaraDemo::BlogAuth::FindBlogUserForAuthUser
}

RACK_CONNECTOR = connector_class.new(authenticator: [:bearer, :api_key], auth_map:) do
  # TODO: we need a reusable way to reuse allowed rules across connectors
  command FoobaraDemo::Blog::StartNewArticle,
          allow_if: :is_author,
          request: { default: { author: -> { blog_user } } }
  command FoobaraDemo::Blog::DeleteArticle, allow_if: :is_article_author
  command FoobaraDemo::Blog::EditArticle, allow_if: :is_article_author
  command FoobaraDemo::Blog::PublishArticle, allow_if: :is_article_author
  command FoobaraDemo::Blog::PublishArticleChanges, allow_if: :is_article_author
  command FoobaraDemo::Blog::UnpublishArticle, allow_if: :is_article_author
  command FoobaraDemo::Blog::FindArticles,
          :aggregate_entities,
          request: { default: { author: -> { blog_user } } },
          allow_if: -> { blog_user == author }

  command FoobaraDemo::BlogAuth::Register
  command FoobaraDemo::BlogAuth::GetCurrentUser,
          :auth,
          :aggregate_entities,
          request: { set: { user: -> { blog_auth_user } } }

  set_user_to_auth_user = { set: { user: -> { authenticated_user } } }
  login_response_mutators = [
    Foobara::AuthHttp::MoveRefreshTokenToCookie.new(secure:),
    Foobara::AuthHttp::MoveAccessTokenToHeader
  ]
  command Foobara::Auth::CreateApiKey,
          :auth,
          inputs: Foobara::AttributesTransformers.reject(:needs_approval),
          request: set_user_to_auth_user
  command Foobara::Auth::GetApiKeySummaries, :auth, request: set_user_to_auth_user
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
  command Foobara::Auth::DeleteApiKey, allow_if: -> { authenticated_user.api_keys.include?(token) }
end
