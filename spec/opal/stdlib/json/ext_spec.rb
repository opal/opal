require 'json'

describe "Hash#to_json" do
  it "returns a string of all key and value pairs" do
    {}.to_json.should == "{}"
    {"a" => 1, "b" => 2}.to_json.should == '{"a":1, "b":2}'

    hash = {"a" => 1, "b" => false, "c" => nil, "d" => true}
    JSON.parse(hash.to_json).should == hash
  end
end

describe "Array#to_json" do
  it "returns a string of all array elements converted to json" do
    [].to_json.should == "[]"
    [1, 2, 3].to_json.should == "[1, 2, 3]"
    [true, nil, false, "3", 42].to_json.should == '[true, null, false, "3", 42]'
  end
end

describe "Boolean#to_json" do
  it "returns 'true' when true" do
    true.to_json.should == "true"
  end

  it "returns 'false' when false" do
    false.to_json.should == "false"
  end
end

describe "Kernel#to_json" do
  it "returns an escaped #to_s of the receiver" do
    self.to_json.should be_kind_of(String)
  end
end

describe "NilClass#to_json" do
  it "returns 'null'" do
    nil.to_json.should == "null"
  end
end

describe "String#to_json" do
  it "returns an escaped string" do
    "foo".to_json.should == "\"foo\""
    "bar\nbaz".to_json.should == "\"bar\\nbaz\""
  end
end
