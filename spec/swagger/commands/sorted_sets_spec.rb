require 'spec_helper'

module Swagger
  describe Redis, 'sorted sets' do

    describe '#zadd' do
      it 'adds a new record' do
        expect_count_to_change { add_record }
      end

      it 'sets the record attributes correctly' do
        record = add_record
        record.key.should eq('key')
        record.score.should eq(100)
        record.value.should eq('value')
      end

      context 'with a record added' do
        let!(:record) { add_record }

        it 'does not add a new record if the values are the same' do
          expect_count_to_not_change { add_record }
        end

        it "updates the record's score if it's different" do
          add_record(:score => 500)
          record.reload.score.should eq(500)
        end

        it 'adds another record if the key is different' do
          expect_count_to_change { add_record(:key => 'key2') }
        end

        it 'adds another record if the value is different' do
          expect_count_to_change { add_record(:value => 'value2') }
        end
      end
    end

    describe '#zrem' do
      context 'with a record added' do
        let!(:record) { add_record(:key => 'k', :value => 'v') }

        it 'deletes the record' do
          expect_count_to_change(-1) { subject.zrem(:k, 'v') }
        end
      end
    end

    describe '#zcard' do
      context 'with 3 records added' do
        before do
          add_record(:score => '1', :value => '#1')
          add_record(:score => '3', :value => '#3')
          add_record(:score => '2', :value => '#2')
        end

        specify { subject.zcard(:key).should eq(3) }
      end
    end

    describe '#zrange' do
      context 'with 5 records added' do
        before do
          add_record(:score => 1, :value => '#1')
          add_record(:score => 3, :value => '#3')
          add_record(:score => 2, :value => '#2')
          add_record(:score => 5, :value => '#5')
          add_record(:score => 4, :value => '#4')
        end

        context 'given the entire range' do
          let(:values) { subject.zrange(:key, 0, -1) }

          specify { values.should have(5).values }

          it 'sorts the values by score' do
            values[0].should eq('#1')
            values[1].should eq('#2')
            values[2].should eq('#3')
            values[3].should eq('#4')
            values[4].should eq('#5')
          end
        end

        context 'given a range of 1 to 3' do
          let(:values) { subject.zrange(:key, 1, 3) }

          specify { values.should have(3).values }

          it 'sorts the values by score' do
            values[0].should eql('#2')
            values[1].should eql('#3')
            values[2].should eql('#4')
          end
        end
      end
    end

    describe '#zrangebyscore' do
      context 'with 5 records added' do
        before do
          add_record(:score => 1, :value => '#1')
          add_record(:score => 3, :value => '#3')
          add_record(:score => 2, :value => '#2')
          add_record(:score => 5, :value => '#5')
          add_record(:score => 4, :value => '#4')
        end

        context 'given the entire range' do
          let(:values) { subject.zrangebyscore(:key, 1, 5) }

          specify { values.should have(5).values }

          it 'sorts the values by score' do
            values[0].should eq('#1')
            values[1].should eq('#2')
            values[2].should eq('#3')
            values[3].should eq('#4')
            values[4].should eq('#5')
          end

          context 'and :limit option' do
            context 'with 1 offset and 3 count' do
              let(:values) do
                subject.zrangebyscore(:key, 1, 5, :limit => [1, 3])
              end

              specify { values.should have(3).values }

              it 'sorts the values by score' do
                values[0].should eq('#2')
                values[1].should eq('#3')
                values[2].should eq('#4')
              end
            end
          end
        end

        context 'given -inf (lowest score) and 3' do
          let(:values) { subject.zrangebyscore(:key, '-inf', 3) }

          specify { values.should have(3).values }

          it 'sorts the values by score' do
            values[0].should eq('#1')
            values[1].should eq('#2')
            values[2].should eq('#3')
          end
        end

        context 'given 3 and +inf (highest score)' do
          let(:values) { subject.zrangebyscore(:key, 3, '+inf') }

          specify { values.should have(3).values }

          it 'sorts the values by score' do
            values[0].should eq('#3')
            values[1].should eq('#4')
            values[2].should eq('#5')
          end
        end
      end
    end

    def add_record(args = {})
      key   = args.fetch(:key)   { 'key' }
      score = args.fetch(:score) { 100 }
      value = args.fetch(:value) { 'value' }

      subject.zadd(key, score, value)
    end

  end
end