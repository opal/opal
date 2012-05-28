describe "String#next" do
  it "returns an empty string for empty strings" do
    "".next.should == ""
  end

  it "returns the successor by increasing the rightmost alphanumeric" do
    "abcd".next.should == "abce"
    "THX1138".next.should == "THX1139"
  end
end