require File.expand_path('../../spec_helper', __FILE__)

describe "The not keyword" do
  it "returns s(:not) with the single argument" do
    parsed("not self").should == [:not, [:self]]
    parsed("not 42").should == [:not, [:int, 42]]
  end
end

describe "The '!' expression" do
  it "returns s(:not) with the single argument" do
    parsed("!self").should == [:not, [:self]]
    parsed("!42").should == [:not, [:int, 42]]
  end
end

describe "The '!=' expression" do
  it "rewrites as !(lhs == rhs)" do
    parsed("1 != 2").should == [:not, [:call, [:int, 1], :==, [:arglist, [:int, 2]]]]
  end
end

describe "The '!~' expression" do
  it "rewrites as !(lhs =~ rhs)" do
    parsed("1 !~ 2").should == [:not, [:call, [:int, 1], :=~, [:arglist, [:int, 2]]]]
  end
end
