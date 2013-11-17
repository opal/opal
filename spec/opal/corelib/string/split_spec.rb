describe "String#split with String" do
  it "returns an array of substrings based on splitting on the given string" do
    "mellow yellow".split("ello").should == ["m", "w y", "w"]
  end
end