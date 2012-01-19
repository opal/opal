require File.expand_path('../../../spec_helper', __FILE__)

describe "Array#flatten" do
  it "returns a one-dimensional flattening recursively" do
    [[[1, [2, 3]], [2, 3, [4, [4, [5, 5]], [1, 2, 3]]], [4]], []].flatten.should == [1, 2, 3, 2, 3, 4, 4, 5, 5, 1, 2, 3, 4]
  end

  it "takes an optional argument that determines the level of recursion" do
    [1, 2, [3, [4, 5]]].flatten(1).should == [1, 2, 3, [4, 5]]
  end

  it "is not destructive" do
    ary = [1, [2, 3]]
    ary.flatten
    ary.should == [1, [2, 3]]
  end
end

describe "Array#flatten!" do
  it "modified array to produce a one-dimensional flattening recursively" do
    a = [[[1, [2, 3]],[2, 3, [4, [4, [5, 5]], [1, 2, 3]]], [4]], []]
    a.flatten!
    a.should == [1, 2, 3, 2, 3, 4, 4, 5, 5, 1, 2, 3, 4]
  end

  it "returns self if made some modifications" do
    a = [[[1, [2, 3]],[2, 3, [4, [4, [5, 5]], [1, 2, 3]]], [4]], []]
    a.flatten!.should equal(a)
  end

  it "returns nil if no modifications took place" do
    a = [1, 2, 3]
    a.flatten!.should == nil
    a = [1, [2, 3]]
    a.flatten!.should_not == nil
  end

  it "takes an optional argument that determines the level of recursion" do
    [1, 2, [3, [4, 5]]].flatten!(1).should == [1, 2, 3, [4, 5]]
  end
end
