require 'support/parser_helpers'

describe "The break keyword" do
  it "should return s(:break) when given no args" do
    expect(parsed("break")).to eq([:break])
  end

  it "returns s(:break) with a single arg not wrapped in s(:array)" do
    expect(parsed("break 1")).to eq([:break, [:int, 1]])
    expect(parsed("break *1")).to eq([:break, [:splat, [:int, 1]]])
  end

  it "returns s(:break) with an s(:array) for args size > 1" do
    expect(parsed("break 1, 2")).to eq([:break, [:array, [:int, 1], [:int, 2]]])
    expect(parsed("break 1, *2")).to eq([:break, [:array, [:int, 1], [:splat, [:int, 2]]]])
  end
end
