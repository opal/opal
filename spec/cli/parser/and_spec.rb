require 'support/parser_helpers'

describe "The and statement" do
  it "should always return s(:and)" do
    expect(parsed("1 and 2")).to eq([:and, [:int, 1], [:int, 2]])
  end
end

describe "The && expression" do
  it "should always return s(:and)" do
    expect(parsed("1 && 2")).to eq([:and, [:int, 1], [:int, 2]])
  end
end
