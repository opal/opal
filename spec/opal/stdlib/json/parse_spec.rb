require 'json'

describe "JSON.parse" do
  it "parses null into nil" do
    expect(JSON.parse("null")).to be_nil
  end

  it "parses true into true" do
    expect(JSON.parse("true")).to be_true
  end

  it "parses false into false" do
    expect(JSON.parse("false")).to be_false
  end

  it "parses numbers into numbers" do
    expect(JSON.parse("42")).to eq(42)
    expect(JSON.parse("3.142")).to eq(3.142)
  end

  it "parses arrays into ruby arrays" do
    expect(JSON.parse("[]")).to eq([])
    expect(JSON.parse("[1, 2, 3]")).to eq([1, 2, 3])
    expect(JSON.parse("[[1, 2, 3], [4, 5]]")).to eq([[1, 2, 3], [4, 5]])
    expect(JSON.parse("[null, true, false]")).to eq([nil, true, false])
  end

  it "parses object literals into ruby hashes" do
    expect(JSON.parse("{}")).to eq({})
    expect(JSON.parse('{"a": "b"}')).to eq({"a" => "b"})
    expect(JSON.parse('{"a": null, "b": 10, "c": [true, false]}')).to eq({"a" => nil, "b" => 10, "c" => [true, false]})
  end
end
