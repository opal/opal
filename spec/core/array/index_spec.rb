describe "Array#index" do
  it "returns the index of the first element == to object" do
    [1, 2, 3, 4, 5, 6].index(3).should == 2
    [1, 2, 3, 4, 5, 6].index(4).should == 3
  end

  it "returns 0 if first element == to object" do
    [2, 1, 3, 2, 5].index(2).should == 0
  end

  it "returns size-1 if only last element == to object" do
    [2, 1, 3, 1, 5].index(5).should == 4
  end

  it "returns nil if no element == to object" do
    [2, 1, 1, 1, 1].index(3).should == nil
  end

  it "accepts a block instead of an argument" do
    [4, 2, 1, 5, 1, 3].index { |x| x < 2 }.should == 2
  end

  it "ignores the block if there is an argument" do
    [4, 2, 1, 5, 1, 3].index(5) { |x| x < 2 }.should == 3
  end
end