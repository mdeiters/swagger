require 'spec_helper'
require 'swagger/active_record'

describe "Swagger::ActiveRecord" do
  before :all do
    Resque.swagger!

    ActiveRecord::Base.establish_connection('adapter' => 'sqlite3', 'database' => ':memory:')
    ActiveRecord::Base.connection.create_table :resque_values do |table|
      table.column :key,      :string
      table.column :key_type, :string
      table.column :value, :text
    end

    ActiveRecord::Base.connection.add_index :resque_values, :key
    ActiveRecord::Base.connection.add_index :resque_values, [:key, :key_type]
  end

  describe "Swagger" do
    it 'sets impersonator_klass' do
      Swagger.impersonator_klass.should == Swagger::ActiveRecord
    end
  end

  describe "Resque" do
    it 'swaps redis implementation with impersonator' do
      Resque.redis.should be_a(Swagger::ActiveRecord)
    end  
    
    it 'can connect to the database' do
      Resque.should.respond_to?(:connect_to_database)
    end
  end

  it_should_behave_like "RedisImpersonator"
end
