require File.expand_path('../../../spec_helper', __FILE__)

describe "Array#concat" do
  it "returns the array itself" do
    ary = [1,2,3]
    ary.concat([4,5,6]).equal?(ary).should be_true
  end

  it "appends the elements in the other array" do
    ary = [1, 2, 3]
    ary.concat([9, 10, 11]).should equal(ary)
    ary.should == [1, 2, 3, 9, 10, 11]
    ary.concat([])
    ary.should == [1, 2, 3, 9, 10, 11]
  end

  it "does not loop endlessly when argument is self" do
    ary = ["x", "y"]
    ary.concat(ary).should == ["x", "y", "x", "y"]
  end
end
