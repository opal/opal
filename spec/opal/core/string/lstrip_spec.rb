describe "String#lstrip" do
  it "returns a copy of self with leading whitespace removed" do
    "    hello    ".lstrip.should == "hello    "
    "    hello world    ".lstrip.should == "hello world    "
    "hello".lstrip.should == "hello"
  end
end