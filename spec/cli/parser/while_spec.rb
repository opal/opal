require 'support/parser_helpers'

describe "The while keyword" do
  it "returns an s(:while) with the given expr, body and true for head" do
    expect(parsed("while 1; 2; end")).to eq([:while, [:int, 1], [:int, 2]])
  end

  it "uses an s(:block) if body has more than one statement" do
    expect(parsed("while 1; 2; 3; end")).to eq([:while, [:int, 1], [:block, [:int, 2], [:int, 3]]])
  end

  it "treats the prefix while statement just like a regular while statement" do
    expect(parsed("1 while 2")).to eq([:while, [:int, 2], [:int, 1]])
  end
end
