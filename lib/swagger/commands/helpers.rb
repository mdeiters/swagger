module Swagger
  module Commands
    module Helpers
      module_function

      def select_values(sql)
        ResqueValue.connection.select_values(sanitize(sql))
      end

      def sanitize(sql)
        ResqueValue.send(:sanitize_sql, sql)
      end

    end
  end
end