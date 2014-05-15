require 'support/parser_helpers'

describe "op_asgn2" do
  it "returns s(:op_asgn2)" do
    expect(parsed('self.foo += 1')[0]).to eq(:op_asgn2)
  end

  it "correctly assigns the receiver" do
    expect(parsed("self.foo += 1")[1]).to eq([:self])
  end

  it "appends '=' onto the identifier in the sexp" do
    expect(parsed("self.foo += 1")[2]).to eq(:foo=)
  end

  it "only uses the operator, not with '=' appended" do
    expect(parsed("self.foo += 1")[3]).to eq(:+)
  end

  it "uses a simple sexp, not an arglist" do
    expect(parsed("self.foo += 1")[4]).to eq([:int, 1])
  end
end
