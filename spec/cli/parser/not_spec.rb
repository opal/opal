require 'support/parser_helpers'

describe "The not keyword" do
  it "returns a call sexp" do
    expect(parsed("not self")).to eq([:call, [:self], '!'.to_sym, [:arglist]])
    expect(parsed("not 42")).to eq([:call, [:int, 42], '!'.to_sym, [:arglist]])
  end
end

describe "The '!' expression" do
  it "returns a call sexp" do
    expect(parsed("!self")).to eq([:call, [:self], '!'.to_sym, [:arglist]])
    expect(parsed("!42")).to eq([:call, [:int, 42], '!'.to_sym, [:arglist]])
  end
end

describe "The '!=' expression" do
  it "rewrites as !(lhs == rhs)" do
    expect(parsed("1 != 2")).to eq([:call, [:call, [:int, 1], :==, [:arglist, [:int, 2]]], '!'.to_sym, [:arglist]])
  end
end

describe "The '!~' expression" do
  it "rewrites as !(lhs =~ rhs)" do
    expect(parsed("1 !~ 2")).to eq([:not, [:call, [:int, 1], :=~, [:arglist, [:int, 2]]]])
  end
end
