require File.expand_path('../../spec_helper', __FILE__)

describe Opal::Parser do
  it "parses instance variables" do
    parsed("@a").should == [:ivar, :@a]
    parsed("@A").should == [:ivar, :@A]
    parsed("@class").should == [:ivar, :@class]
  end

  it "parses instance variable assignment" do
    parsed("@a = 1").should == [:iasgn, :@a, [:int, 1]]
    parsed("@A = 1").should == [:iasgn, :@A, [:int, 1]]
    parsed("@class = 1").should == [:iasgn, :@class, [:int, 1]]
  end

  describe "parses local variables" do
    it "should be created when an identifier is previously assigned to" do
      parsed("a = 1; a").should == [:block, [:lasgn, :a, [:int, 1]], [:lvar, :a]]
      parsed("a = 1; a; a").should == [:block, [:lasgn, :a, [:int, 1]], [:lvar, :a], [:lvar, :a]]
    end

    it "should not be created when no lasgn is previously used on name" do
      parsed("a").should == [:call, nil, :a, [:arglist]]
      parsed("a = 1; b").should == [:block, [:lasgn, :a, [:int, 1]], [:call, nil, :b, [:arglist]]]
    end
  end

  describe "parses local variables inside a def" do
    it "should created by a norm arg" do
      parsed("def a(b); b; end").should == [:def, nil, :a, [:args, :b], [:block, [:lvar, :b]]]
      parsed("def a(b, c); c; end").should == [:def, nil, :a, [:args, :b, :c], [:block, [:lvar, :c]]]
    end

    it "should be created by an opt arg" do
      parsed("def a(b=10); b; end").should == [:def, nil, :a, [:args, :b, [:block, [:lasgn, :b, [:int, 10]]]], [:block, [:lvar, :b]]]
    end

    it "should be created by a rest arg" do
      parsed("def a(*b); b; end").should == [:def, nil, :a, [:args, :"*b"], [:block, [:lvar, :b]]]
    end

    it "should be created by a block arg" do
      parsed("def a(&b); b; end").should == [:def, nil, :a, [:args, :"&b"], [:block, [:lvar, :b]]]
    end

    it "should not be created from locals outside the def" do
      parsed("a = 10; def b; a; end").should == [:block, [:lasgn, :a, [:int, 10]], [:def, nil, :b, [:args], [:block, [:call, nil, :a, [:arglist]]]]]
    end
  end

  it "parses local var assignment" do
    parsed("a = 1").should == [:lasgn, :a, [:int, 1]]
    parsed("a = 1; b = 2").should == [:block, [:lasgn, :a, [:int, 1]], [:lasgn, :b, [:int, 2]]]
  end

  it "parses class variables" do
    parsed("@@foo").should == [:cvar, :@@foo]
  end

  it "parses class variable assignment" do
    parsed("@@foo = 100").should == [:cvdecl, :@@foo, [:int, 100]]
  end

  it "parses global variables" do
    parsed("$foo").should == [:gvar, :$foo]
    parsed("$:").should == [:gvar, :$:]
  end

  it "parses global var assignment" do
    parsed("$foo = 1").should == [:gasgn, :$foo, [:int, 1]]
    parsed("$: = 1").should == [:gasgn, :$:, [:int, 1]]
  end

  it "parses as s(:nth_ref)" do
    parsed('$1').first.should == :nth_ref
  end

  it "references the number 1..9 as first part" do
    parsed('$1').should == [:nth_ref, '1']
    parsed('$9').should == [:nth_ref, '9']
  end

  it "parses constants" do
    parsed("FOO").should == [:const, :FOO]
    parsed("BAR").should == [:const, :BAR]
  end

  it "parses constant assignment" do
    parsed("FOO = 1").should == [:cdecl, :FOO, [:int, 1]]
    parsed("FOO = BAR").should == [:cdecl, :FOO, [:const, :BAR]]
  end
end
