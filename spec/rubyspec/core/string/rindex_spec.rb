describe "String#rindex" do
  it "should return index of last occurrence" do
    "camal".rindex("a").should == 3
  end

  it "should return nil of substring is not found" do
    "camal".rindex("x").should be_nil
  end

  it "should return index of last occurrence from offset" do
    "camal".rindex("a", 1).should == 1
  end

  it "should return nil of last occurrence is after offset" do
    "camal".rindex("a", 0).should be_nil
  end
end
