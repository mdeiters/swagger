require 'spec/spec_helper'

describe 'RedisImpersonator' do
  let(:impersonator) { RedisImpersonator.new }

  
  it 'responds to info' do
    impersonator.info.should_not be_nil
  end
  
  it 'swallows calls to namespace' do
    lambda{impersonator.namespace = 'value'}.should_not raise_error    
  end

  describe 'manipulating key values' do
    it 'it can get key values' do
      impersonator.set('key', 'value').should == 'value'
      impersonator.get('key').should == 'value'
    end
  
    it 'can create new key values' do
      impersonator.set('key', 'value').should == 'value'
      ResqueValue.first.value.should == 'value'
    end
  
    it 'can delete key values' do
      impersonator.set('key', 'value').should == 'value'
      impersonator.del('key')
      impersonator.get('key').should be_nil
    end
    
    it 'can get multiple values by keys' do
      impersonator.set('key-1', 'one')
      impersonator.set('key-2', 'two')
      impersonator.mapped_mget('key-1', 'key-2')['key-1'].should == 'one'
      impersonator.mapped_mget('key-1', 'key-2')['key-2'].should == 'two'
    end
    
    it 'always returns all keys when pattern is *' do
      impersonator.set('key-1', 'one')
      impersonator.set('key-2', 'two')
      impersonator.keys('*').should include('key-1', 'key-2')
    end

    it 'raies error when pattern is not *' do
      lambda{impersonator.keys('something not *')}.should raise_error
    end
  end

  describe 'managing workes in a set' do
    it 'can add workers to the queue' do
      worker = Resque::Worker.new(queues = ['queue1'])
      impersonator.sadd(:workers, worker)
      ResqueValue.first.value.should == worker.to_s
    end
      
    it 'returns all values in the workers set' do
      worker = Resque::Worker.new(queues = ['queue1'])
      impersonator.sadd(:workers, worker)
      impersonator.smembers(:workers).first.should == worker.to_s
    end
  
    it 'removes a worker from the workers set by name' do
      worker = Resque::Worker.new(queues = ['queue1'])
      impersonator.sadd(:workers, worker)
      impersonator.srem(:workers, worker)
      impersonator.smembers(:workers).should be_empty
    end
    
    it 'should only add a value to a set once' do
      impersonator.sadd(:test, 'one')
      impersonator.sadd(:test, 'one')
      impersonator.smembers(:test).size.should == 1
    end
  
    it 'indicates when worker is in the workers set' do
      worker = Resque::Worker.new(queues = ['queue1'])
    
      impersonator.sismember(:workers, worker).should == false
      impersonator.sadd(:workers, worker)
      impersonator.sismember(:workers, worker).should == true    
    end  
    
    it 'can delete a whole set by name'  do
      impersonator.sadd(:test, 'one')
      impersonator.sadd(:test, 'two')
      impersonator.del(:test)
      impersonator.smembers(:test).should be_empty
    end
  end
  
  describe 'working with lists' do
    it 'should return nil if no items on a queue' do
      impersonator.lpop('some_queue').should be_nil
    end
    
    it 'ingores index and adds item to list' do
      impersonator.lset('some_queue', 88, 'value')
      impersonator.llen('some_queue').should == 1
    end
    
    it 'should add item to queue and then pop it back off' do
      impersonator.rpush('some_queue', 'value')
      impersonator.lpop('some_queue').should == 'value'
      impersonator.lpop('some_queue').should be_nil
    end
    
    it 'should tell you how many items are in a list' do
      impersonator.rpush('some_queue', 'one')
      impersonator.rpush('some_queue', 'two')
      impersonator.llen('some_queue').should == 2
    end
    
    it 'should be able to paginate through a list' do
      impersonator.rpush('some_queue', 'one')
      impersonator.rpush('some_queue', 'two')
      impersonator.rpush('some_queue', 'three')        
      impersonator.lrange('some_queue', 0, 1).first.should == 'one'
      impersonator.lrange('some_queue', 2, 3).first.should == 'three'
    end
    
    it 'should get all results if you pass -1 to lrange' do
      impersonator.rpush('some_queue', 'one')
      impersonator.rpush('some_queue', 'two')
      impersonator.rpush('some_queue', 'three')        
      impersonator.lrange('some_queue', 0, -1).should include('one', 'two', 'three')
    end
    
    it 'should remove items from queue' do
      impersonator.rpush('some_queue', 'one')
      impersonator.rpush('some_queue', 'two')
      impersonator.rpush('some_queue', 'two')
      impersonator.lrem('some_queue', 0, 'two').should == 2
      impersonator.lrange('some_queue', 0, -1).should include('one')
    end
    
    it "should trim according to the specifed start and end" do
      1.upto(6){|i| impersonator.rpush('some_queue', i)}
      impersonator.ltrim('some_queue', 1, 3)
      impersonator.llen('some_queue').should == 3
      impersonator.lrange('some_queue', 0, 2).should == ["2","3","4"]
    end
    
    it "should not affect other keys when trimming" do
      1.upto(3){|i| impersonator.rpush('some_queue', i)}
      impersonator.set('something_else', 'independent value')
      impersonator.ltrim('some_queue', 0, 0)
      impersonator.get('something_else').should == 'independent value'
    end
    
    it "should get a range of values" do
      1.upto(6){|i| impersonator.rpush('some_queue', i)}
      impersonator.lrange('some_queue', 0, 5).should == ['1','2','3','4','5','6']
      impersonator.lrange('some_queue', 1, 3).should == ['2','3','4']
    end
    
  end
  
  it 'should increment a value' do
    impersonator.incrby('something', 2)
    impersonator.get('something').should == '2'
    impersonator.incrby('something', 1)
    impersonator.get('something').should == '3'
  end
  
  it 'should decrement a value' do
    impersonator.incrby('something', 2)
    impersonator.get('something').should == '2'
    impersonator.decrby('something', 1)
    impersonator.get('something').should == '1'
  end
end  
