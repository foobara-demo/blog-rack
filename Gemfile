require_relative "version"

source "https://rubygems.org"
ruby FoobaraDemo::BlogRack::MINIMUM_RUBY_VERSION

gemspec

# gem "foobara", path: "../../foobara/foobara"
# gem "foobara-auth", path: "../../foobara/auth"
# gem "foobara-http-command-connector", path: "../../foobara/http-command-connector"

gem "foobara-demo-blog", github: "foobara-demo/blog" # , path: "../blog"
gem "foobara-demo-blog-auth", github: "foobara-demo/blog-auth" # , path: "../blog"

gem "foobara-auth-http" # , path: "../../foobara/auth-http"
gem "foobara-dotenv-loader", "< 2.0.0"
gem "foobara-local-files-crud-driver" # , path: "../../foobara/local-files-crud-driver"
gem "foobara-rack-connector" # , path: "../../foobara/rack-connector"
gem "foobara-redis-crud-driver"
gem "foobara-sh-cli-connector"

gem "puma"
gem "rackup"
gem "rerun"

gem "rake"

group :development do
  gem "foob"
  gem "foobara-rubocop-rules", ">= 1.0.0"
  gem "guard-rspec"
  gem "rubocop-rake"
  gem "rubocop-rspec"
end

group :development, :test do
  gem "debug"
  gem "pry"
  gem "pry-byebug"
  # TODO: Just adding this to suppress warnings seemingly coming from pry-byebug. Can probably remove this once
  # pry-byebug has irb as a gem dependency
  gem "irb"
end

group :test do
  gem "foobara-spec-helpers", "< 2.0.0"
  gem "rack-test"
  gem "rspec"
  gem "rspec-its"
  gem "ruby-prof"
  gem "simplecov"
  gem "vcr"
  gem "webmock"
end
