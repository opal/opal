describe "String#casecmp" do
  it "returns -1 when less than other" do
    "a".casecmp("b").should == -1
    "A".casecmp("b").should == -1
  end
end