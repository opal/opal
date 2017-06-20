require 'spec_helper'
require 'time'

# rubyspec does not have specs for these listed methods
describe Time do
  describe '<=>' do
    it 'returns -1 when self is less than other' do
      (Time.new(2015, 1, 1) <=> Time.new(2015, 1, 2)).should == -1
    end

    it 'returns 0 when self is equal to other' do
      (Time.new(2015, 1, 1) <=> Time.new(2015, 1, 1)).should == 0
    end

    it 'returns 1 when self is greater than other' do
      (Time.new(2015, 1, 2) <=> Time.new(2015, 1, 1)).should == 1
    end

    it 'returns nil when compared to non-Time objects' do
      (Time.new <=> nil).should == nil
    end
  end

  describe "#==" do
    it "returns true if self is equal to other date" do
      (Time.new(2013, 9, 13) == Time.new(2013, 9, 13)).should == true
    end

    it "returns false if self is not equal to other date" do
      (Time.new(2013, 10, 2) == Time.new(2013, 10, 11)).should == false
    end

    it 'returns false when compared to non-Time objects' do
      (Time.new == nil).should == false
      (Time.new == Object.new).should == false
    end
  end

  describe '#zone' do
    context 'with different TZs on Tue Jun 20 20:50:08 UTC 2017' do
      it 'zone is +12' do
        time = Time.now

        # export TZ="/usr/share/zoneinfo/Pacific/Fiji; node -e 'console.log(new Date().toString())'"
        time.JS[:toString] = -> { 'Wed Jun 21 2017 08:42:01 GMT+1200 (+12)' }
        time.zone.should == '+12'

        # export TZ="/usr/share/zoneinfo/Europe/Rome; node -e 'console.log(new Date().toString())'"
        time.JS[:toString] = -> { 'Tue Jun 20 2017 22:52:57 GMT+0200 (CEST)' }
        time.zone.should == 'CEST'

        # export TZ="/usr/share/zoneinfo/Europe/Rome; node -e 'console.log(new Date().toString())'"
        time.JS[:toString] = -> { 'Tue Jun 20 2017 23:56:54 GMT+0300 (MSK)' }
        time.zone.should == 'MSK'
      end
    end
  end
end
