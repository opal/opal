describe "String#ord" do
  it "returns a Fixnum" do
    'a'.ord.should be_kind_of(Numeric)
  end

  it "returns the codepoint of the first character in the String" do
    'a'.ord.should == 97
  end
end