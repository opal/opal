describe "Array#rindex" do
  it "returns the first index backwards from the end where element == to object" do
    [2, 1, 3, 5, 1].rindex(3).should == 2
  end

  it "returns size-1 if last element == to object" do
    [2, 1, 3, 2, 5].rindex(5).should == 4
  end

  it "returns 0 if only first element == to object" do
    [2, 1, 3, 1, 5].rindex(2).should == 0
  end

  it "returns nil if no element == to object" do
    [1, 1, 3, 2, 1, 3].rindex(4).should == nil
  end

  it "accepts a block instead of an argument" do
    [4, 2, 1, 5, 1, 3].rindex { |x| x < 2 }.should == 4
  end
end