require "foobara/redis_crud_driver"

Foobara::Persistence.default_crud_driver = case ENV.fetch("FOOBARA_ENV")
                                           when "test"
                                             Foobara::Persistence::CrudDrivers::InMemory.new
                                           else
                                             # :nocov:
                                             Foobara::RedisCrudDriver.new
                                             # :nocov:
                                           end
