require 'support/parser_helpers'

describe "The yield keyword" do
  it "should return s(:yield) when no arguments given" do
    parsed("yield").should == [:yield]
  end

  it "appends arguments onto end of s(:yield) without an arglist" do
    parsed("yield 1").should == [:yield, [:int, 1]]
    parsed("yield 1, 2").should == [:yield, [:int, 1], [:int, 2]]
    parsed("yield 1, *2").should == [:yield, [:int, 1], [:splat, [:int, 2]]]
  end

  it "accepts parans for any number of arguments" do
    parsed("yield()").should == [:yield]
    parsed("yield(1)").should == [:yield, [:int, 1]]
    parsed("yield(1, 2)").should == [:yield, [:int, 1], [:int, 2]]
    parsed("yield(1, *2)").should == [:yield, [:int, 1], [:splat, [:int, 2]]]
  end
end
