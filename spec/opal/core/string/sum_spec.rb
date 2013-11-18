describe "String#sum" do
  it "returns a basic n-bit checksum of the characters in self" do
    "ruby".sum.should == 450
  end
end