describe "Array#zip" do
  it "returns an array of arrays containing corresponding elements of each array" do
    [1, 2, 3, 4].zip(["a", "b", "c", "d", "e"]).should ==
      [[1, "a"], [2, "b"], [3, "c"], [4, "d"]]
  end

  it "fills in missing values with nil" do
    [1, 2, 3, 4, 5].zip(["a", "b", "c", "d"]).should ==
      [[1, "a"], [2, "b"], [3, "c"], [4, "d"], [5, nil]]
  end

  it "calls block if supplied" do
    values = []
    [1, 2, 3, 4].zip(["a", "b", "c", "d", "e"]) { |value|
      values << value
    }.should == nil

    values.should == [[1, "a"], [2, "b"], [3, "c"], [4, "d"]]
  end
end