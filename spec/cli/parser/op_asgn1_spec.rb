require 'support/parser_helpers'

describe "op_asgn1" do
  it "returns s(:op_asgn1)" do
    expect(parsed('self[:foo] += 1')[0]).to eq(:op_asgn1)
  end

  it "correctly assigns the receiver" do
    expect(parsed("self[:foo] += 1")[1]).to eq([:self])
  end

  it "returns an arglist for args inside braces" do
    expect(parsed("self[:foo] += 1")[2]).to eq([:arglist, [:sym, :foo]])
  end

  it "only uses the operator, not with '=' appended" do
    expect(parsed("self[:foo] += 1")[3]).to eq('+')
  end

  it "uses a simple sexp, not an arglist" do
    expect(parsed("self[:foo] += 1")[4]).to eq([:int, 1])
  end
end
