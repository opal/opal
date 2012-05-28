describe "String#rstrip" do
  it "returns a copy of self with trailing whitespace removed" do
    "    hello    ".rstrip.should == "    hello"
    "    hello world    ".rstrip.should == "    hello world"
    "hello".rstrip.should == "hello"
  end
end