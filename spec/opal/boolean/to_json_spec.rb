require 'json'

describe "Boolean#to_json" do
  it "returns 'true' when true" do
    true.to_json.should == "true"
  end

  it "returns 'false' when false" do
    false.to_json.should == "false"
  end
end
