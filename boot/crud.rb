Foobara::Persistence.default_crud_driver = case ENV.fetch("FOOBARA_ENV")
                                           when "test"
                                             Foobara::Persistence::CrudDrivers::InMemory.new
                                           else
                                             # :nocov:
                                             # require "foobara/redis_crud_driver"
                                             # Foobara::RedisCrudDriver.new

                                             require "foobara/local_files_crud_driver"
                                             Foobara::LocalFilesCrudDriver.new
                                             # :nocov:
                                           end
