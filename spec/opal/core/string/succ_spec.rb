describe "String#succ" do
  it "returns an empty string for empty strings" do
    "".succ.should == ""
  end

  it "returns the successor by increasing the rightmost alphanumeric" do
    "abcd".succ.should == "abce"
    "THX1138".succ.should == "THX1139"
  end
end