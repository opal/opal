require 'support/parser_helpers'

describe "The not keyword" do
  it "returns a call sexp" do
    parsed("not self").should == [:call, [:self], '!'.to_sym, [:arglist]]
    parsed("not 42").should == [:call, [:int, 42], '!'.to_sym, [:arglist]]
  end
end

describe "The '!' expression" do
  it "returns a call sexp" do
    parsed("!self").should == [:call, [:self], '!'.to_sym, [:arglist]]
    parsed("!42").should == [:call, [:int, 42], '!'.to_sym, [:arglist]]
  end
end

describe "The '!=' expression" do
  it "rewrites as !(lhs == rhs)" do
    parsed("1 != 2").should == [:call, [:call, [:int, 1], :==, [:arglist, [:int, 2]]], '!'.to_sym, [:arglist]]
  end
end

describe "The '!~' expression" do
  it "rewrites as !(lhs =~ rhs)" do
    parsed("1 !~ 2").should == [:not, [:call, [:int, 1], :=~, [:arglist, [:int, 2]]]]
  end
end
