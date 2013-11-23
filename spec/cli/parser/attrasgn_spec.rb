require File.expand_path('../../spec_helper', __FILE__)

describe "Attribute assignments" do
  it "should return a s(:attrasgn) for simple assignments" do
    opal_parse('self.foo = 1').should == [:attrasgn, [:self], :foo=, [:arglist, [:int, 1]]]
    opal_parse('bar.foo = 1').should == [:attrasgn, [:call, nil, :bar, [:arglist]], :foo=, [:arglist, [:int, 1]]]
    opal_parse('@bar.foo = 1').should == [:attrasgn, [:ivar, :@bar], :foo=, [:arglist, [:int, 1]]]
  end

  it "accepts both '.' and '::' for method call operators" do
    opal_parse('self.foo = 1').should == [:attrasgn, [:self], :foo=, [:arglist, [:int, 1]]]
    opal_parse('self::foo = 1').should == [:attrasgn, [:self], :foo=, [:arglist, [:int, 1]]]
  end

  it "can accept a constant as assignable name when using '.'" do
    opal_parse('self.FOO = 1').should == [:attrasgn, [:self], :FOO=, [:arglist, [:int, 1]]]
  end

  describe "when setting element reference" do
    it "uses []= as the method call" do
      opal_parse('self[1] = 2').should == [:attrasgn, [:self], :[]=, [:arglist, [:int, 1], [:int, 2]]]
    end

    it "supports multiple arguments inside brackets" do
      opal_parse('self[1, 2] = 3').should == [:attrasgn, [:self], :[]=, [:arglist, [:int, 1], [:int, 2], [:int, 3]]]
    end
  end
end
