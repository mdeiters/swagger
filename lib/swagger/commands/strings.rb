module Swagger
  module Commands
    module Strings

      def get(key)
        resque_value = ResqueValue.first(:conditions => {:key => key})
        resque_value.value if resque_value
      end

      def set(key, value)
        resque_value = ResqueValue.find_or_initialize_by_key(key.to_s)
        resque_value.value = value
        resque_value.save!
        value
      end

      def setnx(key, value)
        resque_value = ResqueValue.find_or_initialize_by_key(key.to_s)
        if resque_value.new_record?
          resque_value.value = value
          resque_value.save!
        end
        resque_value.value
      end

      def incr(key)
        incrby(key, '1')
      end

      def decr(key)
        decrby(key, '1')
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

    end
  end
end