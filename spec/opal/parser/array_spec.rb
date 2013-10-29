require 'spec_helper'

describe "Arrays" do
  it "should parse empty arrays as s(:array)" do
    opal_parse("[]").should == [:array]
  end

  it "should append regular args onto end of array sexp" do
    opal_parse("[1]").should == [:array, [:int, 1]]
    opal_parse("[1, 2]").should == [:array, [:int, 1], [:int, 2]]
    opal_parse("[1, 2, 3]").should == [:array, [:int, 1], [:int, 2], [:int, 3]]
  end

  it "should return a single item s(:array) with given splat if no norm args" do
    opal_parse("[*1]").should == [:array, [:splat, [:int, 1]]]
  end

  it "should allow splats combined with any number of norm args" do
    opal_parse("[1, *2]").should == [:array, [:int, 1], [:splat, [:int, 2]]]
    opal_parse("[1, 2, *3]").should == [:array, [:int, 1], [:int, 2], [:splat, [:int, 3]]]
  end
end
