Resque.module_eval do
  def swagger!
    define_method(:redis=) do |*args|
      @redis = RedisImpersonator.new
    end
  end  
end