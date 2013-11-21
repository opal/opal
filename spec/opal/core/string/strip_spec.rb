describe "String#strip" do
  it "returns a new string with leading and trailing whitespace removed" do
    "    hello    ".strip.should == "hello"
    "    hello world    ".strip.should == "hello world"
  end
end