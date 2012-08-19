describe "String#length" do
  it "returns the length of self" do
    "".length.should == 0
    "one".length.should == 3
    "two".length.should == 3
    "three".length.should == 5
    "four".length.should == 4
  end
end