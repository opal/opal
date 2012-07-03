require 'spec_helper'

describe "Attribute assignments" do
  it "should return a s(:attrasgn) for simple assignments" do
    opal_parse('self.foo = 1').should == [:attrasgn, [:self], :foo=, [:arglist, [:lit, 1]]]
    opal_parse('bar.foo = 1').should == [:attrasgn, [:call, nil, :bar, [:arglist]], :foo=, [:arglist, [:lit, 1]]]
    opal_parse('@bar.foo = 1').should == [:attrasgn, [:ivar, :@bar], :foo=, [:arglist, [:lit, 1]]]
  end

  it "accepts both '.' and '::' for method call operators" do
    opal_parse('self.foo = 1').should == [:attrasgn, [:self], :foo=, [:arglist, [:lit, 1]]]
    opal_parse('self::foo = 1').should == [:attrasgn, [:self], :foo=, [:arglist, [:lit, 1]]]
  end

  it "can accept a constant as assignable name when using '.'" do
    opal_parse('self.FOO = 1').should == [:attrasgn, [:self], :FOO=, [:arglist, [:lit, 1]]]
  end

  describe "when setting element reference" do
    it "uses []= as the method call" do
      opal_parse('self[1] = 2').should == [:attrasgn, [:self], :[]=, [:arglist, [:lit, 1], [:lit, 2]]]
    end

    it "supports multiple arguments inside brackets" do
      opal_parse('self[1, 2] = 3').should == [:attrasgn, [:self], :[]=, [:arglist, [:lit, 1], [:lit, 2], [:lit, 3]]]
    end
  end
end
