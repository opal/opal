describe "String#capitalize" do
  it "returns a copy of self with the first character converted to uppercase and the remainder to lowercase" do
    "".capitalize.should == ""
    "h".capitalize.should == "H"
    "H".capitalize.should == "H"
    "hello".capitalize.should == "Hello"
    "HELLO".capitalize.should == "Hello"
    "123ABC".capitalize.should == "123abc"
  end
end