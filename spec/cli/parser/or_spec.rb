require 'support/parser_helpers'

describe "The or statement" do
  it "should always return s(:or)" do
    expect(parsed("1 or 2")).to eq([:or, [:int, 1], [:int, 2]])
  end
end

describe "The || expression" do
  it "should always return s(:or)" do
    expect(parsed("1 || 2")).to eq([:or, [:int, 1], [:int, 2]])
  end
end
