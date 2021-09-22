require 'spec_helper'

describe 'Number#to_s' do
  it "should convert 0.0 to '0.0'" do
    0.0.to_s.should == '0'
  end

  it "should convert -0.0 to '-0.0'" do
    -0.0.to_s.should == '-0.0'
  end
end
