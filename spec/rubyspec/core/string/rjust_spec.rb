describe "String#rjust" do
  it "does nothing if the specified width is lower than the string's size" do
    "abc".rjust(2).should == "abc"
  end

  it "uses default padding" do
    "abc".rjust(5).should == "abc  "
  end

  it "uses a custum padding" do
    "abc".rjust(5, '-').should == "abc--"
  end

  it "uses wisely a bigger pattern" do
    "abc".rjust(10, "123").should == "abc1231231"
  end
end
