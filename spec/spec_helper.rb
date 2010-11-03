require 'rubygems'
require 'resque'
require 'swagger'

Spec::Runner.configure do |config|

  config.prepend_before :each do
    ResqueValue.delete_all
  end  
  
end

Resque.swagger!

ActiveRecord::Base.establish_connection('adapter' => 'sqlite3', 'database' => ':memory:')
ActiveRecord::Base.connection.create_table :resque_values do |table|
  table.column :key,      :string
  table.column :key_type, :string
  table.column :value, :text
end

ActiveRecord::Base.connection.add_index :resque_values, :key
ActiveRecord::Base.connection.add_index :resque_values, [:key, :key_type]
