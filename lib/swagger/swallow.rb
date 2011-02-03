module Swagger
  module Swallow

    def swallow(method, return_value = nil)
      define_method(method) do |*args|
        if defined?(LOGGER)
          LOGGER.write "Swagger::Redis swallowed #{method} with the following arguments #{args.inspect}"
        end
        return_value
      end
    end

  end
end