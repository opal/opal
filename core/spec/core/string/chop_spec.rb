describe "String#chop" do
  it "returns a new string with the last character removed" do
    "hello\n".chop.should == "hello"
    "hello".chop.should == "hell"
  end

  it "returns an empty string when applied to an empty string" do
    "".chop.should == ""
  end
end