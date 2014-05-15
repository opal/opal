require 'support/parser_helpers'

describe "The if keyword" do
  it "should return an s(:if) with given truthy and falsy bodies" do
    expect(parsed("if 1; 2; else; 3; end")).to eq([:if, [:int, 1], [:int, 2], [:int, 3]])
  end

  it "uses nil as fasly body if not given else-then" do
    expect(parsed("if 1; 2; end")).to eq([:if, [:int, 1], [:int, 2], nil])
  end

  it "is treats elsif parts as sub if expressions for else body" do
    expect(parsed("if 1; 2; elsif 3; 4; else; 5; end")).to eq([:if, [:int, 1], [:int, 2], [:if, [:int, 3], [:int, 4], [:int, 5]]])
    expect(parsed("if 1; 2; elsif 3; 4; end")).to eq([:if, [:int, 1], [:int, 2], [:if, [:int, 3], [:int, 4], nil]])
  end

  it "returns a simple s(:if) with nil else body for prefix if statement" do
    expect(parsed("1 if 2")).to eq([:if, [:int, 2], [:int, 1], nil])
  end
end

describe "The ternary operator" do
  it "gets converted into an if statement with true and false parts" do
    expect(parsed("1 ? 2 : 3")).to eq([:if, [:int, 1], [:int, 2], [:int, 3]])
  end
end
