require File.expand_path('../../../spec_helper', __FILE__)

describe "Array#first" do
  it "returns the first element" do
    %w[a b c].first.should == 'a'
    [nil].first.should == nil
  end

  it "returns nil if self is empty" do
    [].first.should == nil
  end

  it "returns the first count elements if given a count" do
    [true, false, true, nil, false].first(2).should == [true, false]
  end

  it "returns an empty array when passed count on an empty array" do
    [].first(0).should == []
    [].first(1).should == []
    [].first(2).should == []
  end

  it "returns an empty array when passed count == 0" do
    [1, 2, 3, 4, 5].first(0).should == []
  end

  it "returns an array containing the first element when passed count == 1" do
    [1, 2, 3, 4, 5].first(1).should == [1]
  end

  it "returns the entire array when count > length" do
    [1, 2, 3, 4, 5, 9].first(10).should == [1, 2, 3, 4, 5, 9]
  end

  it "returns an array which is independent to the original when passed count" do
    ary = [1, 2, 3, 4, 5]
    ary.first(0).replace([1, 2])
    [1, 2, 3, 4, 5].should == ary
    ary.first(1).replace([1, 2])
    [1, 2, 3, 4, 5].should == ary
    ary.first(6).replace([1, 2])
    [1, 2, 3, 4, 5].should == ary
  end

  it "is not destructive" do
    a = [1, 2, 3]
    a.first
    a.should == [1, 2, 3]
    a.first(2)
    a.should == [1, 2, 3]
    a.first(3)
    a.should == [1, 2, 3]
  end
end

]

