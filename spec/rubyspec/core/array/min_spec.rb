require File.expand_path('../../../spec_helper', __FILE__)

describe "Array#min" do
  it "should return min of values in numeric array" do
    [1, 2].min.should == 1
  end

  it "should return min of values in string array" do
    ["1", "2"].min.should == "1"
  end

  it "should return nil if array is empty" do
    [].min.should be_nil 
  end

  it "should raise ArgumentError if array contains a non-Comparable value" do
    lambda { [true, false].min }.should raise_error(ArgumentError)
  end

  it "should use block when specified to compare values" do
    [1, 2, 3].min {|candidate, current| candidate <=> current }.should == 1
  end

  it "should use break value from block when block is specified" do
    [1, 2, 3].max {|candidate, current| break -5 }.should == -5
  end

  it "should allow block to compare non-Comparable values" do
    [true, false].min {|candidate, current| candidate ? 1 : -1 }.should == false
    [true, false].min {|candidate, current| candidate ? -1 : 1 }.should == true
  end
end
