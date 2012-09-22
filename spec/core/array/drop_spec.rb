describe "Array#drop" do
  it "removes the specified number of elements from the start of the array" do
    [1, 2, 3, 4, 5].drop(2).should == [3, 4, 5]
  end

  it "returns an empty Array if all elements are dropped" do
    [1, 2].drop(2).should == []
  end

  it "returns an empty Array when called on an empty Array" do
    [].drop(0).should == []
  end

  it "does not drop any elements when passed zero" do
    [1, 2].drop(0).should == [1, 2]
  end

  it "returns an empty Array if more elements than exist are dropped" do
    [1, 2].drop(3).should == []
  end
end