module Swagger
  module ResqueStubs
    def redis=(*args)
      @redis = Swagger::RedisImpersonator.new
    end
    
    def connect_to_database(database)
      ResqueValue.establish_connection database
    end
  end  

  module ResqueStubber
    def swagger!
      Resque.send(:extend, ResqueStubs)
    end
  end
end

Resque.send(:extend, Swagger::ResqueStubber)
