require File.expand_path('../../spec_helper', __FILE__)

describe "The alias keyword" do
  describe "with fitem" do
    it "should return an s(:alias) with s(:sym)" do
      opal_parse("alias a b").should == [:alias, [:sym, :a], [:sym, :b]]
      opal_parse("alias == equals").should == [:alias, [:sym, :==], [:sym, :equals]]
    end

    it "should accept symbols as names" do
      opal_parse("alias :foo :bar").should == [:alias, [:sym, :foo], [:sym, :bar]]
    end
  end

  describe "with gvar" do
    it "should return a s(:valias) with two gvars as arguments" do
      opal_parse("alias $foo $bar").should == [:valias, :$foo, :$bar]
    end
  end

  describe "with gvar and nth ref" do
    it "should return a s(:valias) with two values as arguments" do
      opal_parse("alias $foo $1").should == [:valias, :$foo, :"1"]
    end
  end
end
