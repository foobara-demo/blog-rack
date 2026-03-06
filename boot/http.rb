require "foobara/rack_connector"
require "foobara/entities_plumbing"

authenticator = [:bearer, :api_key]

RACK_CONNECTOR = Foobara::CommandConnectors::Http::Rack.new(authenticator:, **FoobaraDemo::BlogRack::PERMISSIONS) do
  command FoobaraDemo::Blog::StartNewArticle, request: { default: { author: -> { blog_user } } }
  command FoobaraDemo::Blog::DeleteArticle
  command FoobaraDemo::Blog::EditArticle
  command FoobaraDemo::Blog::PublishArticle
  command FoobaraDemo::Blog::PublishArticleChanges
  command FoobaraDemo::Blog::UnpublishArticle
  command FoobaraDemo::Blog::FindArticle, :aggregate_entities
  command FoobaraDemo::Blog::FindArticles,
          :aggregate_entities,
          request: { default: { author: -> { blog_user } } }
  command FoobaraDemo::Blog::FindArticleSummaries,
          :aggregate_entities,
          request: { default: { author: -> { blog_user } } }

  command FoobaraDemo::BlogAuth::Register
  command FoobaraDemo::BlogAuth::GetCurrentUser,
          :aggregate_entities,
          allow_if: :always,
          request: { set: { user: -> { blog_auth_user } } }

  env = ENV["FOOBARA_ENV"]
  login_response_mutators = [
    Foobara::AuthHttp::MoveRefreshTokenToCookie.new(secure: env != "development" && env != "test"),
    Foobara::AuthHttp::MoveAccessTokenToHeader
  ]

  command Foobara::Auth::CreateApiKey,
          inputs: Foobara::AttributesTransformers.reject(:needs_approval),
          request: { set: { user: -> { authenticated_user } } },
          allow_if: :always
  command Foobara::Auth::GetApiKeySummaries, :auth, request: { set: { user: -> { authenticated_user } } }
  command Foobara::Auth::Login, requires_authentication: false,
                                inputs: { only: [:username_or_email, :plaintext_password] },
                                response: login_response_mutators
  command Foobara::Auth::RefreshLogin, requires_authentication: false,
                                       request: Foobara::AuthHttp::SetRefreshTokenFromCookie,
                                       inputs: { only: :refresh_token },
                                       response: login_response_mutators
  command Foobara::Auth::Logout, request: Foobara::AuthHttp::SetRefreshTokenFromCookie,
                                 response: Foobara::AuthHttp::ClearAccessTokenHeader
  command Foobara::Auth::DeleteApiKey
end
