require 'rubygems'
require 'resque'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'swagger'
require 'spec'
require 'spec/autorun'

Spec::Runner.configure do |config|

  config.prepend_before :each do
    ResqueValue.delete_all
  end  
  
end

Resque.swagger!

ActiveRecord::Base.establish_connection('adapter' => 'sqlite3', 'database' => 'test.db')

ActiveRecord::Base.connection.drop_table :resque_values rescue puts "unable to drop resque_values, probably because it has not been created yet"
ActiveRecord::Base.connection.create_table :resque_values do |table|
  table.column :key,      :string
  table.column :key_type, :string
  table.column :value, :text
end

ActiveRecord::Base.connection.add_index :resque_values, :key
ActiveRecord::Base.connection.add_index :resque_values, [:key, :key_type]

