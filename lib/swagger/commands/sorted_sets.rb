module Swagger
  module Commands
    module SortedSets

      KEY_TYPE = 'sorted_set'

      def zadd(key, score, value)
        record = ResqueValue.find_or_initialize_by_key_and_key_type_and_value(
          key, KEY_TYPE, value)
        record.score = score
        record.save
        record
      end

      def zrem(key, value)
        ResqueValue.delete_all conditions(key).merge(:value => value)
      end

      def zcard(key)
        ResqueValue.count :conditions => conditions(key)
      end

      def zrange(key, start, stop)
        Helpers.select_values(
          'SELECT value FROM resque_values ' \
          "WHERE key = #{key} " \
          'ORDER BY score'
        )[start..stop]
      end

      def zrangebyscore(key, min, max, options = {})
        min = ResqueValue.minimum(:score, :conditions => conditions(key)) || 0 if min == '-inf'
        max = ResqueValue.maximum(:score, :conditions => conditions(key)) || 0 if max == '+inf'

        Helpers.select_values(
          [].tap do |sql|
            sql << 'SELECT value FROM resque_values'
            sql << "WHERE 'key' = '#{key}'"
            sql << "AND score BETWEEN #{min} AND #{max}"
            sql << 'ORDER BY score'
            if limit = options[:limit]
              sql << "LIMIT #{limit.join(', ')}"
            end
          end.join(' ')
        )
      end

    private

      def conditions(key)
        { :key => key, :key_type => KEY_TYPE }
      end

    end
  end
end