module Swagger
  module Commands
    module Lists
      KEY_TYPE = 'list'

      def llen(list_name)
        ResqueValue.all(:conditions => {:key => list_name.to_s, :key_type=> KEY_TYPE }).size
      end

      def lset(list_name, index, value)
        rpush(list_name, value)
      end

      def lrange(list_name, start_range, end_range)
        options = { :conditions => {
                      :key => list_name.to_s,
                      :key_type=> KEY_TYPE}}
        unless end_range < 0
          limit = end_range - start_range + 1
          options.merge!(:limit => limit, :offset => start_range)
        end
        values = ResqueValue.all(options)
        values.map(&:value)
      end

      def lrem(list_name, count, value)
        raise "Only supports count of 0 which means to remove all elements in list" if count != 0
        ResqueValue.delete_all(:key => list_name.to_s, :key_type=> KEY_TYPE, :value => value )
      end

      def lpop(list_name)
        ResqueValue.transaction do
          last = ResqueValue.last(:conditions => {:key => list_name.to_s, :key_type => KEY_TYPE}, :lock => true)
          if last
            last.destroy
            return last.value
          end
        end
      end

      def rpush(list_name, value)
        ResqueValue.create!(:key => list_name.to_s, :key_type => KEY_TYPE, :value => value.to_s)
      end

      def ltrim(list_name, start_range, end_range)
        limit = end_range - start_range + 1
        ids = ResqueValue.all(:select => "id", :conditions => {:key => list_name}, :offset => start_range, :limit => limit)
        ResqueValue.delete_all(["`key` = ? AND id NOT IN (?)", list_name, ids.collect{|i| i.id}])
      end

    end
  end
end