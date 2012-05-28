describe "String#partition" do
  it "returns an array of substrings based on splitting on the given string" do
    "hello world".partition("o").should == ["hell", "o", " world"]
  end

  it "always returns 3 elements" do
    "hello".partition("x").should == ["hello", "", ""]
    "hello".partition("hello").should == ["", "hello", ""]
  end
end