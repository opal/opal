require 'spec_helper'

describe "The alias keyword" do
  describe "with fitem" do
    it "should return an s(:alias) with s(:lit)" do
      opal_parse("alias a b").should == [:alias, [:lit, :a], [:lit, :b]]
      opal_parse("alias == equals").should == [:alias, [:lit, :==], [:lit, :equals]]
    end

    it "should accept symbols as names" do
      opal_parse("alias :foo :bar").should == [:alias, [:lit, :foo], [:lit, :bar]]
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
