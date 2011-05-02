
describe "Array#concat" do
  it "appends the elements in the other array" do
    ary = [1, 2, 3]
    ary.concat([9, 10, 11])
    ary.should == [1, 2, 3, 9, 10, 11]
    ary.concat []
    ary.should == [1, 2, 3, 9, 10, 11]
  end
  
  it "does not loop endlessly when argument is self" do
    ary = ["x", "y"]
    ary.concat(ary).should == ["x", "y", "x", "y"]
  end
end
