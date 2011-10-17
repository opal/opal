require File.expand_path('../../../spec_helper', __FILE__)

describe "TrueClass#class" do
  it "should return true for the 'true' literal, otherwise false" do
    true.class.should == TrueClass
    (false.class == TrueClass).should == false
    (nil.class == TrueClass).should == false
  end
end

