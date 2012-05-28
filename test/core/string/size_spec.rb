describe "String#size" do
  it "returns the length of self" do
    "".size.should == 0
    "one".size.should == 3
    "two".size.should == 3
    "three".size.should == 5
    "four".size.should == 4
  end
end