require 'spec_helper'

module Swagger
  describe Redis, 'strings' do

    describe '#setnx' do
      it 'adds a new record' do
        expect_count_to_change { add_record }
      end

      it 'sets the record attributes correctly' do
        record = add_record
        record.key.should eq('key')
        record.value.should eq('value')
      end

      context 'with a record added' do
        let!(:record) { add_record }

        it 'does not add a new record if the values are the same' do
          expect_count_to_not_change { add_record }
        end

        it "does not update the record's value if it's different" do
          add_record(:value => 'foo')
          record.reload.value.should eq('value')
        end
      end
    end

    describe '#incr' do
      let!(:record) { add_record(:value => '1') }

      it "increments a record's value by one" do
        subject.incr('key')
        record.reload.value.should eq('2')
      end
    end

    describe '#decr' do
      let!(:record) { add_record(:value => '1') }

      it "decrements a record's value by one" do
        subject.decr('key')
        record.reload.value.should eq('0')
      end
    end

    def add_record(args = {})
      key   = args.fetch(:key)   { 'key' }
      value = args.fetch(:value) { 'value' }

      subject.setnx(key, value)
      ResqueValue.find_by_key_and_value(key, value)
    end

  end
end