require 'spec_helper'

describe "An lvar" do
  describe "in any scope" do
    it "should be created when an identifier is previously assigned to" do
      opal_parse("a = 1; a").should == [:block, [:lasgn, :a, [:lit, 1]], [:lvar, :a]]
      opal_parse("a = 1; a; a").should == [:block, [:lasgn, :a, [:lit, 1]], [:lvar, :a], [:lvar, :a]]
    end

    it "should not be created when no lasgn is previously used on name" do
      opal_parse("a").should == [:call, nil, :a, [:arglist]]
      opal_parse("a = 1; b").should == [:block, [:lasgn, :a, [:lit, 1]], [:call, nil, :b, [:arglist]]]
    end
  end

  describe "inside a def" do
    it "should created by a norm arg" do
      opal_parse("def a(b); b; end").should == [:defn, :a, [:args, :b], [:scope, [:block, [:lvar, :b]]]]
      opal_parse("def a(b, c); c; end").should == [:defn, :a, [:args, :b, :c], [:scope, [:block, [:lvar, :c]]]]
    end

    it "should be created by an opt arg" do
      opal_parse("def a(b=10); b; end").should == [:defn, :a, [:args, :b, [:block, [:lasgn, :b, [:lit, 10]]]], [:scope, [:block, [:lvar, :b]]]]
    end

    it "should be created by a rest arg" do
      opal_parse("def a(*b); b; end").should == [:defn, :a, [:args, :"*b"], [:scope, [:block, [:lvar, :b]]]]
    end

    it "should be created by a block arg" do
      opal_parse("def a(&b); b; end").should == [:defn, :a, [:args, :"&b"], [:scope, [:block, [:lvar, :b]]]]
    end

    it "should not be created from locals outside the def" do
      opal_parse("a = 10; def b; a; end").should == [:block, [:lasgn, :a, [:lit, 10]], [:defn, :b, [:args], [:scope, [:block, [:call, nil, :a, [:arglist]]]]]]
    end
  end
end
