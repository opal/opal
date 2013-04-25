describe "Array#to_json" do
  it "returns a string of all array elements converted to json" do
    [].to_json.should == "[]"
    [1, 2, 3].to_json.should == "[1, 2, 3]"
    [true, nil, false, "3", 42].to_json.should == '[true, null, false, "3", 42]'
  end
end