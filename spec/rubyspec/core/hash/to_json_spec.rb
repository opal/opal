require 'json'

describe "Hash#to_json" do
  it "returns a string of all key and value pairs" do
    {}.to_json.should == "{}"
    {"a" => 1, "b" => 2}.to_json.should == '{"a": 1, "b": 2}'

    hash = {"a" => 1, "b" => false, "c" => nil, "d" => true}
    JSON.parse(hash.to_json).should == hash
  end
end
