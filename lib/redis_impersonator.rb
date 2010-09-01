class RedisImpersonator
  SET  = 'set'
  LIST = 'list'
  
  def self.swallow(method, return_value = nil)
    define_method(method) do |*args|
      LOGGER.write("RedisImpersonator: Swallowed #{method} with the following arguments #{args.inspect}") if defined?(LOGGER)
      return_value
    end
  end
  swallow(:namespace=)
  swallow(:namespace, 'not applicable')
  swallow(:server, 'ActiveRecord')
  swallow(:info,   self.inspect)
    
  def srem(set_name, value)
    ResqueValue.delete_all(:key => set_name.to_s, :key_type => SET, :value => value.to_s)
    nil
  end
  
  def smembers(set_name)
    ResqueValue.all(:conditions => {:key => set_name.to_s, :key_type => SET}).map(&:value)
  end

  def sismember(set_name, value)
    ResqueValue.exists?(:key => set_name.to_s, :key_type => SET, :value => value.to_s)
  end
  
  def sadd(set_name, value)
    sismember(set_name, value) || ResqueValue.create!(:key => set_name.to_s, :key_type => SET, :value => value.to_s)
  end
  
  def set(key, value)
    resque_value = ResqueValue.find_or_initialize_by_key(key.to_s)
    resque_value.value = value
    resque_value.save!
    value
  end

  def get(key)
    resque_value = ResqueValue.first(:conditions => {:key => key})
    resque_value.value if resque_value
  end
  
  def del(key)
    ResqueValue.delete_all(:key => key.to_s)
    nil
  end
  
  def exists(key)
    ResqueValue.exists?(:key => key.to_s)
  end
  
  def incrby(key, value)
    object = ResqueValue.find_or_initialize_by_key(key.to_s)
    object.value = (object.value.to_i + value.to_i).to_s
    object.save!
    object.value    
  end
  
  def decrby(key, value)
    object = ResqueValue.find_or_initialize_by_key(key.to_s)
    object.value = (object.value.to_i - value.to_i).to_s
    object.save!
    object.value
  end
    
  def mapped_mget(*keys)
    Hash[*keys.zip(mget(*keys)).flatten]
  end
  
  def mget(*keys)
    keys.collect!{|key| key.to_s }
    resque_values = ResqueValue.all(:conditions => {:key => keys})
    resque_values.map(&:value)    
  end    
      
  def llen(list_name)
    ResqueValue.all(:conditions => {:key => list_name.to_s, :key_type=> LIST }).size
  end
  
  def lset(list_name, index, value)
    rpush(list_name, value)
  end
    
  def lrange(list_name, start_range, end_range)
    options = { :conditions => {
                  :key => list_name.to_s,
                  :key_type=> LIST}}
    unless end_range < 0
      limit = end_range - start_range + 1
      options.merge!(:limit => limit, :offset => start_range)
    end
    values = ResqueValue.all(options)
    values.map(&:value)
  end
  
  def lrem(list_name, count, value)
    raise "Only supports count of 0 which means to remove all elements in list" if count != 0
    ResqueValue.delete_all(:key => list_name.to_s, :key_type=> LIST, :value => value )
  end
  
  def lpop(list_name)
    ResqueValue.transaction do
      last = ResqueValue.last(:conditions => {:key => list_name.to_s, :key_type => LIST})
      if last
        last.destroy
        return last.value
      end
    end
  end
  
  def rpush(list_name, value)
    ResqueValue.create!(:key => list_name.to_s, :key_type => LIST, :value => value.to_s)
  end
  
  def ltrim(list_name, start_range, end_range)
    limit = end_range - start_range + 1
    ids = ResqueValue.all(:select => "id", :conditions => {:key => list_name}, :offset => start_range, :limit => limit)
    ResqueValue.delete_all(["id NOT IN (?)", ids.collect{|i| i.id}])
  end
  
  def keys(pattern = '*')
    raise "Pattern '#{pattern}' not supported" if pattern != '*'
    ResqueValue.all(:select => 'DISTINCT resque_values.key').map(&:key)
  end

end