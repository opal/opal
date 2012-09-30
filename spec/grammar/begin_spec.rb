require 'spec_helper'

describe "The begin keyword" do
  it "should be removed when used without a resuce or enusre body" do
    opal_parse('begin; 1; end').should == [:lit, 1]
    opal_parse('begin; 1; 2; end').should == [:block, [:lit, 1], [:lit, 2]]
  end

  describe "with 'rescue' bodies" do
    it "should create a s(:rescue) sexp" do
      opal_parse('begin; 1; rescue; 2; end').should == [:rescue, [:lit, 1], [:resbody, [:array], [:lit, 2]]]
    end

    it "allows multiple rescue bodies" do
      opal_parse('begin 1; rescue; 2; rescue; 3; end').should == [:rescue, [:lit, 1], [:resbody, [:array], [:lit, 2]], [:resbody, [:array], [:lit, 3]]]
    end

    it "accepts a list of classes used to match against the exception" do
      opal_parse('begin 1; rescue Klass; 2; end').should == [:rescue, [:lit, 1], [:resbody, [:array, [:const, :Klass]], [:lit, 2]]]
    end

    it "accepts an identifier to assign exception to" do
      opal_parse('begin 1; rescue => a; 2; end').should == [:rescue, [:lit, 1], [:resbody, [:array, [:lasgn, :a, [:gvar, :$!]]], [:lit, 2]]]
      opal_parse('begin 1; rescue Klass => a; 2; end').should == [:rescue, [:lit, 1], [:resbody, [:array, [:const, :Klass],[:lasgn, :a, [:gvar, :$!]]], [:lit, 2]]]
    end

    it "accepts an ivar to assign exception to" do
      opal_parse('begin 1; rescue => @a; 2; end').should == [:rescue, [:lit, 1], [:resbody, [:array, [:iasgn, :@a, [:gvar, :$!]]], [:lit, 2]]]
      opal_parse('begin 1; rescue Klass => @a; 2; end').should == [:rescue, [:lit, 1], [:resbody, [:array, [:const, :Klass],[:iasgn, :@a, [:gvar, :$!]]], [:lit, 2]]]
    end
  end

  describe "with an 'ensure' block" do
    it "should propagate into single s(:ensure) statement when no rescue block given" do
      opal_parse('begin; 1; ensure; 2; end').should == [:ensure, [:lit, 1], [:lit, 2]]
    end
  end
end
