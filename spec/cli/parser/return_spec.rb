require 'support/parser_helpers'

describe "The return keyword" do
  it "should return s(:return) when given no arguments" do
    expect(parsed("return")).to eq([:return])
  end

  it "returns s(:return) with the direct argument when given one argument" do
    expect(parsed("return 1")).to eq([:return, [:int, 1]])
    expect(parsed("return *2")).to eq([:return, [:splat, [:int, 2]]])
  end

  it "returns s(:return) with an s(:array) when args size > 1" do
    expect(parsed("return 1, 2")).to eq([:return, [:array, [:int, 1], [:int, 2]]])
    expect(parsed("return 1, *2")).to eq([:return, [:array, [:int, 1], [:splat, [:int, 2]]]])
  end
end
