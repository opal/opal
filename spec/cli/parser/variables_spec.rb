require File.expand_path('../../spec_helper', __FILE__)

describe Opal::Parser do
  it "parses instance variables" do
    opal_parse("@a").should == [:ivar, :@a]
    opal_parse("@A").should == [:ivar, :@A]
    opal_parse("@class").should == [:ivar, :@class]
  end

  it "parses instance variable assignment" do
    opal_parse("@a = 1").should == [:iasgn, :@a, [:int, 1]]
    opal_parse("@A = 1").should == [:iasgn, :@A, [:int, 1]]
    opal_parse("@class = 1").should == [:iasgn, :@class, [:int, 1]]
  end

  describe "parses local variables" do
    it "should be created when an identifier is previously assigned to" do
      opal_parse("a = 1; a").should == [:block, [:lasgn, :a, [:int, 1]], [:lvar, :a]]
      opal_parse("a = 1; a; a").should == [:block, [:lasgn, :a, [:int, 1]], [:lvar, :a], [:lvar, :a]]
    end

    it "should not be created when no lasgn is previously used on name" do
      opal_parse("a").should == [:call, nil, :a, [:arglist]]
      opal_parse("a = 1; b").should == [:block, [:lasgn, :a, [:int, 1]], [:call, nil, :b, [:arglist]]]
    end
  end

  describe "parses local variables inside a def" do
    it "should created by a norm arg" do
      opal_parse("def a(b); b; end").should == [:def, nil, :a, [:args, :b], [:block, [:lvar, :b]]]
      opal_parse("def a(b, c); c; end").should == [:def, nil, :a, [:args, :b, :c], [:block, [:lvar, :c]]]
    end

    it "should be created by an opt arg" do
      opal_parse("def a(b=10); b; end").should == [:def, nil, :a, [:args, :b, [:block, [:lasgn, :b, [:int, 10]]]], [:block, [:lvar, :b]]]
    end

    it "should be created by a rest arg" do
      opal_parse("def a(*b); b; end").should == [:def, nil, :a, [:args, :"*b"], [:block, [:lvar, :b]]]
    end

    it "should be created by a block arg" do
      opal_parse("def a(&b); b; end").should == [:def, nil, :a, [:args, :"&b"], [:block, [:lvar, :b]]]
    end

    it "should not be created from locals outside the def" do
      opal_parse("a = 10; def b; a; end").should == [:block, [:lasgn, :a, [:int, 10]], [:def, nil, :b, [:args], [:block, [:call, nil, :a, [:arglist]]]]]
    end
  end

  it "parses local var assignment" do
    opal_parse("a = 1").should == [:lasgn, :a, [:int, 1]]
    opal_parse("a = 1; b = 2").should == [:block, [:lasgn, :a, [:int, 1]], [:lasgn, :b, [:int, 2]]]
  end

  it "parses class variables" do
    opal_parse("@@foo").should == [:cvar, :@@foo]
  end

  it "parses class variable assignment" do
    opal_parse("@@foo = 100").should == [:cvdecl, :@@foo, [:int, 100]]
  end

  it "parses global variables" do
    opal_parse("$foo").should == [:gvar, :$foo]
    opal_parse("$:").should == [:gvar, :$:]
  end

  it "parses global var assignment" do
    opal_parse("$foo = 1").should == [:gasgn, :$foo, [:int, 1]]
    opal_parse("$: = 1").should == [:gasgn, :$:, [:int, 1]]
  end

  it "parses as s(:nth_ref)" do
    opal_parse('$1').first.should == :nth_ref
  end

  it "references the number 1..9 as first part" do
    opal_parse('$1').should == [:nth_ref, '1']
    opal_parse('$9').should == [:nth_ref, '9']
  end

  it "parses constants" do
    opal_parse("FOO").should == [:const, :FOO]
    opal_parse("BAR").should == [:const, :BAR]
  end

  it "parses constant assignment" do
    opal_parse("FOO = 1").should == [:cdecl, :FOO, [:int, 1]]
    opal_parse("FOO = BAR").should == [:cdecl, :FOO, [:const, :BAR]]
  end
end
