require 'spec/spec_helper'

describe 'Resque' do
  
  it 'swaps redis implementation with impersonator' do
    Resque.swagger!
    Resque.redis.should be_a(RedisImpersonator)
  end  
end
