require File.expand_path('../../spec_helper', __FILE__)

describe "The not keyword" do
  it "returns s(:not) with the single argument" do
    opal_parse("not self").should == [:not, [:self]]
    opal_parse("not 42").should == [:not, [:int, 42]]
  end
end

describe "The '!' expression" do
  it "returns s(:not) with the single argument" do
    opal_parse("!self").should == [:not, [:self]]
    opal_parse("!42").should == [:not, [:int, 42]]
  end
end

describe "The '!=' expression" do
  it "rewrites as !(lhs == rhs)" do
    opal_parse("1 != 2").should == [:not, [:call, [:int, 1], :==, [:arglist, [:int, 2]]]]
  end
end

describe "The '!~' expression" do
  it "rewrites as !(lhs =~ rhs)" do
    opal_parse("1 !~ 2").should == [:not, [:call, [:int, 1], :=~, [:arglist, [:int, 2]]]]
  end
end
