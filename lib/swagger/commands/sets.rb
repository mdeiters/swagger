module Swagger
  module Commands
    module Sets
      KEY_TYPE = 'set'

      def sadd(set_name, value)
        sismember(set_name, value) || ResqueValue.create!(:key => set_name.to_s, :key_type => KEY_TYPE, :value => value.to_s)
      end

      def srem(set_name, value)
        ResqueValue.delete_all(:key => set_name.to_s, :key_type => KEY_TYPE, :value => value.to_s)
        nil
      end

      def smembers(set_name)
        ResqueValue.all(:conditions => {:key => set_name.to_s, :key_type => KEY_TYPE}).map(&:value)
      end

      def sismember(set_name, value)
        ResqueValue.exists?(:key => set_name.to_s, :key_type => KEY_TYPE, :value => value.to_s)
      end

    end
  end
end