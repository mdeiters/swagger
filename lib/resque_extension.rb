Resque.module_eval do
  def swagger!
    define_method(:redis=) do |*args|
      @redis = RedisImpersonator.new
    end
    
    define_method(:connect_to_database) do |database|
      ResqueValue.establish_connection(database)
    end
  end  
end