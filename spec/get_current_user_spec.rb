RSpec.describe FoobaraDemo::BlogAuth::GetCurrentUser do
  include Rack::Test::Methods

  let(:app) { command_connector }
  let(:command_connector) { RACK_CONNECTOR }

  context "when not authenticated" do
    it "is a 401" do
      get "/run/GetCurrentUser"
      expect(last_response.status).to be(401)
    end
  end

  context "when authenticated" do
    stub_env_var("JWT_SECRET", "test-secret")

    let(:blog_auth_user) do
      FoobaraDemo::BlogAuth::Register.run!(
        username: "fumiko",
        email:,
        plaintext_password:,
        full_name: "Fumiko"
      )
    end
    let(:email) { "fumiko@example.com" }
    let(:plaintext_password) { "password" }

    let(:access_token) do
      blog_auth_user
      post "/run/Login",
           JSON.generate(username_or_email: email, plaintext_password:),
           "CONTENT_TYPE" => "application/json"

      expect(last_response.status).to be(200)
      last_response.headers["x-access-token"]
    end

    it "is a 200" do
      get "/run/GetCurrentUser", {}, "HTTP_AUTHORIZATION" => "Bearer #{access_token}"
      expect(last_response.status).to be(200)
    end
  end
end
