describe "Array#&" do
  it "creates an array with elements common to both arrays (intersection)" do
    ([] & []).should == []
    ([1, 2] & []).should == []
    ([] & [1, 2]).should == []
    ([1, 3, 5] & [1, 2, 3]).should == [1, 3]
  end

  it "creates an array with no duplicates" do
    ([1, 1, 3, 5] & [1, 2, 3]).uniq!.should == nil
  end

  it "creates an array with elements in order they are first encountered" do
    ([1, 2, 3, 2, 5] & [5, 2, 3, 4]).should == [2, 3, 5]
  end

  it "does not modify the original Array" do
    a = [1, 1, 3, 5]
    a & [1, 2, 3]
    a.should == [1, 1, 3, 5]
  end
end