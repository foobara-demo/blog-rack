require "foobara/rack_connector"

require "foobara_demo/blog"

rack_connector = Foobara::CommandConnectors::Http::Rack.new

rack_connector.connect(FoobaraDemo::Blog)

RACK_CONNECTOR = rack_connector
