describe "Numeric#to_json" do
  it "returns a string representing the number" do
    42.to_json.should == "42"
    3.142.to_json.should == "3.142"
  end
end