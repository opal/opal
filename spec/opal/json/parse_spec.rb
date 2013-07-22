require 'json'

describe "JSON.parse" do
  it "parses null into nil" do
    JSON.parse("null").should be_nil
  end

  it "parses true into true" do
    JSON.parse("true").should be_true
  end

  it "parses false into false" do
    JSON.parse("false").should be_false
  end

  it "parses numbers into numbers" do
    JSON.parse("42").should == 42
    JSON.parse("3.142").should == 3.142
  end

  it "parses arrays into ruby arrays" do
    JSON.parse("[]").should == []
    JSON.parse("[1, 2, 3]").should == [1, 2, 3]
    JSON.parse("[[1, 2, 3], [4, 5]]").should == [[1, 2, 3], [4, 5]]
    JSON.parse("[null, true, false]").should == [nil, true, false]
  end

  it "parses object literals into ruby hashes" do
    JSON.parse("{}").should == {}
    JSON.parse('{"a": "b"}').should == {"a" => "b"}
    JSON.parse('{"a": null, "b": 10, "c": [true, false]}').should == {"a" => nil, "b" => 10, "c" => [true, false]}
  end
end
