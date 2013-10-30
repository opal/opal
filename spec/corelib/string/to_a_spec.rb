describe "String#to_a" do
  it "returns an empty array for empty strings" do
    "".to_a.should == []
  end

  it "returns an array containing the string for non-empty strings" do
    "hello".to_a.should == ["hello"]
  end
end