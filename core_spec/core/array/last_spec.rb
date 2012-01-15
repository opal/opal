require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../fixtures/classes', __FILE__)

describe "Array#last" do
  it "returns the last element" do
    [1, 1, 1, 1, 2].last.should == 2
  end

  it "returns nil if self is empty" do
    [].last.should == nil
  end

  it "returns the last count elements if given a count" do
    [1, 2, 3, 4, 5, 9].last(3).should == [4, 5, 9]
  end

  it "returns an empty array when passed a count on an empty array" do
    [].last(0).should == []
    [].last(1).should == []
  end

  it "returns an empty array when count == 0" do
    [1, 2, 3, 4, 5].last(0).should == []
  end

  it "returns an array containing the last element when passed count == 1" do
    [1, 2, 3, 4, 5].last(1).should == [5]
  end

  it "raises an ArgumentError when count is negative" do
    lambda { [1, 2].last(-1) }.should raise_error(ArgumentError)
  end

  it "returns the entire array when count > length" do
    [1, 2, 3, 4, 5, 9].last(10).should == [1, 2, 3, 4, 5, 9]
  end

  it "returns an array which is independent to the original when passed count" do
    ary = [1, 2, 3, 4, 5]
    ary.last(0).replace([1,2])
    ary.should == [1, 2, 3, 4, 5]
    ary.last(1).replace([1,2])
    ary.should == [1, 2, 3, 4, 5]
    ary.last(6).replace([1,2])
    ary.should == [1, 2, 3, 4, 5]
  end

  it "is not destructive" do
    a = [1, 2, 3]
    a.last
    a.should == [1, 2, 3]
    a.last(2)
    a.should == [1, 2, 3]
    a.last(3)
    a.should == [1, 2, 3]
  end
end
