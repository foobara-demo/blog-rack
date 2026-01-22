ENV["FOOBARA_ENV"] ||= "development"

require "bundler/setup"

if ["development", "test"].include?(ENV["FOOBARA_ENV"])
  # :nocov:
  if ENV["RUBY_DEBUG"] == "true"
    require "debug"
  elsif ENV["SKIP_PRY"] != "true" && ENV["CI"] != "true"
    require "pry"
    require "pry-byebug" unless ENV["SKIP_BYEBUG"] == "true"
  end
  # :nocov:
end

require_relative "config"
