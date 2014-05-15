require 'support/parser_helpers'

describe "The yield keyword" do
  it "should return s(:yield) when no arguments given" do
    expect(parsed("yield")).to eq([:yield])
  end

  it "appends arguments onto end of s(:yield) without an arglist" do
    expect(parsed("yield 1")).to eq([:yield, [:int, 1]])
    expect(parsed("yield 1, 2")).to eq([:yield, [:int, 1], [:int, 2]])
    expect(parsed("yield 1, *2")).to eq([:yield, [:int, 1], [:splat, [:int, 2]]])
  end

  it "accepts parans for any number of arguments" do
    expect(parsed("yield()")).to eq([:yield])
    expect(parsed("yield(1)")).to eq([:yield, [:int, 1]])
    expect(parsed("yield(1, 2)")).to eq([:yield, [:int, 1], [:int, 2]])
    expect(parsed("yield(1, *2)")).to eq([:yield, [:int, 1], [:splat, [:int, 2]]])
  end
end
