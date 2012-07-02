require 'spec_helper'

describe "Arrays" do
  it "should parse empty arrays as s(:array)" do
    opal_parse("[]").should == [:array]
  end

  it "should append regular args onto end of array sexp" do
    opal_parse("[1]").should == [:array, [:lit, 1]]
    opal_parse("[1, 2]").should == [:array, [:lit, 1], [:lit, 2]]
    opal_parse("[1, 2, 3]").should == [:array, [:lit, 1], [:lit, 2], [:lit, 3]]
  end

  it "should return a single item s(:array) with given splat if no norm args" do
    opal_parse("[*1]").should == [:array, [:splat, [:lit, 1]]]
  end

  it "should allow splats combined with any number of norm args" do
    opal_parse("[1, *2]").should == [:array, [:lit, 1], [:splat, [:lit, 2]]]
    opal_parse("[1, 2, *3]").should == [:array, [:lit, 1], [:lit, 2], [:splat, [:lit, 3]]]
  end
end
