require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../fixtures/classes', __FILE__)

describe "Array#reject" do
  it "returns a new array without elements for which block is true" do
    ary = [1, 2, 3, 4, 5]
    ary.reject { true }.should == []
    ary.reject { false }.should == ary
    ary.reject { false }.object_id.should_not == ary.object_id
    ary.reject { nil }.should == ary
    ary.reject { nil }.object_id.should_not == ary.object_id
    ary.reject { |i| i < 3 }.should == [3, 4, 5]
    ary.reject { |i| i % 2 == 0 }.should == [1, 3, 5]
  end

  it "returns self when called on an Array emptied with #shift" do
    array = [1]
    array.shift
    array.reject { |x| true }.should == []
  end
end

describe "Array#reject!" do
  it "removes elements for which block is true" do
    a = [3, 4, 5, 6, 7, 8, 9, 10, 11]
    a.reject! { |i| i % 2 == 0 }.should equal(a)
    a.should == [3, 5, 7, 9, 11]
    a.reject! { |i| i > 8 }
    a.should == [3, 5, 7]
    a.reject! { |i| i < 4 }
    a.should == [5, 7]
    a.reject! { |i| i == 5 }
    a.should == [7]
    a.reject! { true }
    a.should == []
    a.reject! { true }
    a.should == []
  end

  it "returns nil when called on an array emptied with #shift" do
    array = [1]
    array.shift
    array.reject! { |x| true }.should == nil
  end

  it "returns nil if no changes are made" do
    a = [1, 2, 3]

    a.reject! { |i| i < 0 }.should == nil

    a.reject! { true }
    a.reject! { true }.should == nil
  end
end
