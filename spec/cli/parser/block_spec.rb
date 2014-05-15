require 'support/parser_helpers'

describe "Block statements" do
  it "should return the direct expression if only one expresssion in block" do
    expect(parsed("42")).to eq([:int, 42])
  end

  it "should return an s(:block) with all expressions appended for > 1 expression" do
    expect(parsed("42; 43")).to eq([:block, [:int, 42], [:int, 43]])
    expect(parsed("42; 43\n44")).to eq([:block, [:int, 42], [:int, 43], [:int, 44]])
  end
end
