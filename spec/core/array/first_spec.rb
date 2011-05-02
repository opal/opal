
describe "Array#first" do
  it "returns the first element" do
    # %W{a b c}.first.should == 'a'
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
  
  it "raises an argument error when count is negative"
  
  it "returns the entire array when count > length" do
    [1, 2, 3, 4, 5, 6, 7, 8, 9].first(10).should == [1, 2, 3, 4, 5, 6, 7, 8, 9]
  end
end
