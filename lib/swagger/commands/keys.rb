module Swagger
  module Commands
    module Keys

      def del(key)
        ResqueValue.delete_all(:key => key.to_s)
        nil
      end

      def exists(key)
        ResqueValue.exists?(:key => key.to_s)
      end

      def keys(pattern = '*')
        raise "Pattern '#{pattern}' not supported" if pattern != '*'
        ResqueValue.all(:select => 'DISTINCT resque_values.key').map(&:key)
      end

    end
  end
end