describe "String#empty?" do
  it "returns true if the string has a length of zero" do
    "hello".empty?.should == false
    " ".empty?.should == false
    "".empty?.should == true
  end
end