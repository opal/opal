describe "Boolean#to_s" do
  it "returns 'true' when true" do
    true.to_json.should == "true"
  end

  it "returns 'false' when false" do
    false.to_json.should == "false"
  end
end