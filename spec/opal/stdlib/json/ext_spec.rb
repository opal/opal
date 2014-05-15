require 'json'

describe "Hash#to_json" do
  it "returns a string of all key and value pairs" do
    expect({}.to_json).to eq("{}")
    expect({"a" => 1, "b" => 2}.to_json).to eq('{"a":1, "b":2}')

    hash = {"a" => 1, "b" => false, "c" => nil, "d" => true}
    expect(JSON.parse(hash.to_json)).to eq(hash)
  end
end

describe "Array#to_json" do
  it "returns a string of all array elements converted to json" do
    expect([].to_json).to eq("[]")
    expect([1, 2, 3].to_json).to eq("[1, 2, 3]")
    expect([true, nil, false, "3", 42].to_json).to eq('[true, null, false, "3", 42]')
  end
end

describe "Boolean#to_json" do
  it "returns 'true' when true" do
    expect(true.to_json).to eq("true")
  end

  it "returns 'false' when false" do
    expect(false.to_json).to eq("false")
  end
end

describe "Kernel#to_json" do
  it "returns an escaped #to_s of the receiver" do
    expect(self.to_json).to be_kind_of(String)
  end
end

describe "NilClass#to_json" do
  it "returns 'null'" do
    expect(nil.to_json).to eq("null")
  end
end

describe "String#to_json" do
  it "returns an escaped string" do
    expect("foo".to_json).to eq("\"foo\"")
    expect("bar\nbaz".to_json).to eq("\"bar\\nbaz\"")
  end
end
