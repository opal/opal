require 'support/parser_helpers'

describe "The unless keyword" do
  it "returns s(:if) with reversed true and false bodies" do
    expect(parsed("unless 10; 20; end")).to eq([:if, [:int, 10], nil, [:int, 20]])
    expect(parsed("unless 10; 20; 30; end")).to eq([:if, [:int, 10], nil, [:block, [:int, 20], [:int, 30]]])
    expect(parsed("unless 10; 20; else; 30; end")).to eq([:if, [:int, 10], [:int, 30], [:int, 20]])
  end

  it "returns s(:if) with reversed true and false bodies for prefix unless" do
    expect(parsed("20 unless 10")).to eq([:if, [:int, 10], nil, [:int, 20]])
  end
end
