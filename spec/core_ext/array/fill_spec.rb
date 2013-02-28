require "spec_helper"

describe "Array#fill" do
  it "returns self" do
    ary = [1, 2, 3]
    ary.fill(:a).should equal(ary)
  end

  it "is destructive" do
    ary = [1, 2, 3]
    ary.fill(:a)
    ary.should == [:a, :a, :a]
  end

  it "replaces all elements in the array with the filler if not given an index nor a length" do
    ary = ['a', 'b', 'c', 'duh']
    ary.fill(8).should == [8, 8, 8, 8]

    str = "x"
    ary.fill(str).should == [str, str, str, str]
  end

  it "replaces all elements with the value of block (index given to block)" do
    [nil, nil, nil, nil].fill { |i| i * 2 }.should == [0, 2, 4, 6]
  end
end
