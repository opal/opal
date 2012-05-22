describe "String#chr" do
  it "returns an empty String if self is an empty String" do
    "".chr.should == ""
  end

  it "returns a 1-character String" do
    "glark".chr.size.should == 1
  end

  it "returns the character at the start of the String" do
    "Goodbye, world".chr.should == "G"
  end
end