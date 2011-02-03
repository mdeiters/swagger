require 'spec_helper'

module Swagger
  describe Redis do
    it 'responds to info' do
      subject.info.should_not be_nil
    end

    it 'swallows calls to namespace' do
      lambda{subject.namespace = 'value'}.should_not raise_error
    end

    describe 'manipulating key values' do
      it 'it can get key values' do
        subject.set('key', 'value').should == 'value'
        subject.get('key').should == 'value'
      end

      it 'can create new key values' do
        subject.set('key', 'value').should == 'value'
        ResqueValue.first.value.should == 'value'
      end

      it 'can delete key values' do
        subject.set('key', 'value').should == 'value'
        subject.del('key')
        subject.get('key').should be_nil
      end

      it 'can get multiple values by keys' do
        subject.set('key-1', 'one')
        subject.set('key-2', 'two')
        subject.mapped_mget('key-1', 'key-2')['key-1'].should == 'one'
        subject.mapped_mget('key-1', 'key-2')['key-2'].should == 'two'
      end

      it 'always returns all keys when pattern is *' do
        subject.set('key-1', 'one')
        subject.set('key-2', 'two')
        subject.keys('*').should include('key-1', 'key-2')
      end

      it 'raises error when pattern is not *' do
        lambda{subject.keys('something not *')}.should raise_error
      end
    end

    describe 'managing workes in a set' do
      it 'can add workers to the queue' do
        worker = Resque::Worker.new(queues = ['queue1'])
        subject.sadd(:workers, worker)
        ResqueValue.first.value.should == worker.to_s
      end

      it 'returns all values in the workers set' do
        worker = Resque::Worker.new(queues = ['queue1'])
        subject.sadd(:workers, worker)
        subject.smembers(:workers).first.should == worker.to_s
      end

      it 'removes a worker from the workers set by name' do
        worker = Resque::Worker.new(queues = ['queue1'])
        subject.sadd(:workers, worker)
        subject.srem(:workers, worker)
        subject.smembers(:workers).should be_empty
      end

      it 'should only add a value to a set once' do
        subject.sadd(:test, 'one')
        subject.sadd(:test, 'one')
        subject.smembers(:test).size.should == 1
      end

      it 'indicates when worker is in the workers set' do
        worker = Resque::Worker.new(queues = ['queue1'])

        subject.sismember(:workers, worker).should == false
        subject.sadd(:workers, worker)
        subject.sismember(:workers, worker).should == true
      end

      it 'can delete a whole set by name'  do
        subject.sadd(:test, 'one')
        subject.sadd(:test, 'two')
        subject.del(:test)
        subject.smembers(:test).should be_empty
      end
    end

    describe 'working with lists' do
      it 'should return nil if no items on a queue' do
        subject.lpop('some_queue').should be_nil
      end

      it 'ingores index and adds item to list' do
        subject.lset('some_queue', 88, 'value')
        subject.llen('some_queue').should == 1
      end

      it 'should add item to queue and then pop it back off' do
        subject.rpush('some_queue', 'value')
        subject.lpop('some_queue').should == 'value'
        subject.lpop('some_queue').should be_nil
      end

      it 'should tell you how many items are in a list' do
        subject.rpush('some_queue', 'one')
        subject.rpush('some_queue', 'two')
        subject.llen('some_queue').should == 2
      end

      it 'should be able to paginate through a list' do
        subject.rpush('some_queue', 'one')
        subject.rpush('some_queue', 'two')
        subject.rpush('some_queue', 'three')
        subject.lrange('some_queue', 0, 1).first.should == 'one'
        subject.lrange('some_queue', 2, 3).first.should == 'three'
      end

      it 'should get all results if you pass -1 to lrange' do
        subject.rpush('some_queue', 'one')
        subject.rpush('some_queue', 'two')
        subject.rpush('some_queue', 'three')
        subject.lrange('some_queue', 0, -1).should include('one', 'two', 'three')
      end

      it 'should remove items from queue' do
        subject.rpush('some_queue', 'one')
        subject.rpush('some_queue', 'two')
        subject.rpush('some_queue', 'two')
        subject.lrem('some_queue', 0, 'two').should == 2
        subject.lrange('some_queue', 0, -1).should include('one')
      end

      it "should trim according to the specifed start and end" do
        1.upto(6){|i| subject.rpush('some_queue', i)}
        subject.ltrim('some_queue', 1, 3)
        subject.llen('some_queue').should == 3
        subject.lrange('some_queue', 0, 2).should == ["2","3","4"]
      end

      it "should not affect other keys when trimming" do
        1.upto(3){|i| subject.rpush('some_queue', i)}
        subject.set('something_else', 'independent value')
        subject.ltrim('some_queue', 0, 0)
        subject.get('something_else').should == 'independent value'
      end

      it "should get a range of values" do
        1.upto(6){|i| subject.rpush('some_queue', i)}
        subject.lrange('some_queue', 0, 5).should == ['1','2','3','4','5','6']
        subject.lrange('some_queue', 1, 3).should == ['2','3','4']
      end
    end

    it 'should increment a value' do
      subject.incrby('something', 2)
      subject.get('something').should == '2'
      subject.incrby('something', 1)
      subject.get('something').should == '3'
    end

    it 'should decrement a value' do
      subject.incrby('something', 2)
      subject.get('something').should == '2'
      subject.decrby('something', 1)
      subject.get('something').should == '1'
    end

  end
end