RSpec.describe FoobaraDemo::Blog::FindArticles do
  include Rack::Test::Methods

  let(:app) { command_connector }
  let(:blog_auth_user) do
    FoobaraDemo::BlogAuth::Register.run!(
      username: "fumiko",
      email:,
      plaintext_password:,
      full_name: "Fumiko"
    )
  end
  let(:blog_user) { blog_auth_user.blog_user }
  let(:email) { "fumiko@example.com" }
  let(:plaintext_password) { "password" }
  let(:command_connector) { RACK_CONNECTOR }

  stub_env_var("JWT_SECRET", "test-secret")

  context "when there's an article" do
    before do
      post "/run/StartNewArticle",
           JSON.generate(author: blog_user, title: "some article"),
           "HTTP_AUTHORIZATION" => "Bearer #{access_token}"
      expect(last_response.status).to be(200)
    end

    context "when authenticated" do
      let(:access_token) do
        blog_auth_user
        post "/run/Login",
             JSON.generate(username_or_email: email, plaintext_password:),
             "CONTENT_TYPE" => "application/json"

        expect(last_response.status).to be(200)
        last_response.headers["x-access-token"]
      end

      it "is a 200 and gives an API key" do
        get "/run/FindArticles", {}, "HTTP_AUTHORIZATION" => "Bearer #{access_token}"
        expect(last_response.status).to be(200)
        result = JSON.parse(last_response.body)

        expect(result.size).to be(1)
        expect(result.first["title"]).to eq("some article")
      end
    end
  end
end
