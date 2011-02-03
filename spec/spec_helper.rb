require 'rubygems'
require 'bundler'
Bundler.setup

require 'resque'
require 'swagger'

Dir['./spec/support/*.rb'].map {|f| require f }

RSpec.configure do |config|
  config.color_enabled = true
  config.before { ResqueValue.delete_all }
end

Resque.swagger!

ActiveRecord::Base.establish_connection('adapter' => 'sqlite3', 'database' => 'test.db')

begin
  ActiveRecord::Base.connection.drop_table :resque_values
rescue
  puts "unable to drop resque_values, probably because it has not been created yet"
end

ActiveRecord::Base.connection.create_table :resque_values do |table|
  table.column :key,      :string
  table.column :key_type, :string
  table.column :score,    :integer
  table.column :value,    :text
  table.timestamps
end

ActiveRecord::Base.connection.add_index :resque_values, :key
ActiveRecord::Base.connection.add_index :resque_values, [:key, :key_type]