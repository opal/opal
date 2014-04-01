require 'cli/spec_helper'

describe "Attribute assignments" do
  it "should return a s(:attrasgn) for simple assignments" do
    parsed('self.foo = 1').should == [:attrasgn, [:self], :foo=, [:arglist, [:int, 1]]]
    parsed('bar.foo = 1').should == [:attrasgn, [:call, nil, :bar, [:arglist]], :foo=, [:arglist, [:int, 1]]]
    parsed('@bar.foo = 1').should == [:attrasgn, [:ivar, :@bar], :foo=, [:arglist, [:int, 1]]]
  end

  it "accepts both '.' and '::' for method call operators" do
    parsed('self.foo = 1').should == [:attrasgn, [:self], :foo=, [:arglist, [:int, 1]]]
    parsed('self::foo = 1').should == [:attrasgn, [:self], :foo=, [:arglist, [:int, 1]]]
  end

  it "can accept a constant as assignable name when using '.'" do
    parsed('self.FOO = 1').should == [:attrasgn, [:self], :FOO=, [:arglist, [:int, 1]]]
  end

  describe "when setting element reference" do
    it "uses []= as the method call" do
      parsed('self[1] = 2').should == [:attrasgn, [:self], :[]=, [:arglist, [:int, 1], [:int, 2]]]
    end

    it "supports multiple arguments inside brackets" do
      parsed('self[1, 2] = 3').should == [:attrasgn, [:self], :[]=, [:arglist, [:int, 1], [:int, 2], [:int, 3]]]
    end
  end
end
