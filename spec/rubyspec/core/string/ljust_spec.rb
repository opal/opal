describe "String#ljust" do
  it "does nothing if the specified width is lower than the string's size" do
    "abc".ljust(2).should == "abc"
  end

  it "uses default padding" do
    "abc".ljust(5).should == "  abc"
  end

  it "uses a custum padding" do
    "abc".ljust(5, '-').should == "--abc"
  end

  it "uses wisely a bigger pattern" do
    "abc".ljust(10, "123").should == "1231231abc"
  end
end
