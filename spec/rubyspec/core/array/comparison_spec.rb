describe "Array#<=>" do
  it "returns 0 if the arrays are equal" do
    ([] <=> []).should == 0
    ([1, 2, 3, 4, 5, 6] <=> [1, 2, 3, 4, 5, 6]).should == 0
  end

  it "returns -1 if the array is shorter than the other array" do
    ([] <=> [1]).should == -1
    ([1, 1] <=> [1, 1, 1]).should == -1
  end

  it "returns +1 if the array is longer than the other array" do
    ([1] <=> []).should == 1
    ([1, 1, 1] <=> [1, 1]).should == 1
  end
end