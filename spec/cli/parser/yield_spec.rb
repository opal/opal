require File.expand_path('../../spec_helper', __FILE__)

describe "The yield keyword" do
  it "should return s(:yield) when no arguments given" do
    opal_parse("yield").should == [:yield]
  end

  it "appends arguments onto end of s(:yield) without an arglist" do
    opal_parse("yield 1").should == [:yield, [:int, 1]]
    opal_parse("yield 1, 2").should == [:yield, [:int, 1], [:int, 2]]
    opal_parse("yield 1, *2").should == [:yield, [:int, 1], [:splat, [:int, 2]]]
  end

  it "accepts parans for any number of arguments" do
    opal_parse("yield()").should == [:yield]
    opal_parse("yield(1)").should == [:yield, [:int, 1]]
    opal_parse("yield(1, 2)").should == [:yield, [:int, 1], [:int, 2]]
    opal_parse("yield(1, *2)").should == [:yield, [:int, 1], [:splat, [:int, 2]]]
  end
end
