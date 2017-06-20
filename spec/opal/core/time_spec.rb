require 'spec_helper'
require 'time'

# rubyspec does not have specs for these listed methods
describe Time do
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
