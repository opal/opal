require File.expand_path('../../spec_helper', __FILE__)

describe Opal::Parser do

  it "parses true keyword" do
    opal_parse("true").should == [:true]
  end

  it "true cannot be assigned to" do
    lambda {
      opal_parse "true = 1"
    }.should raise_error(Exception)
  end

  it "parses false keyword" do
    opal_parse("false").should == [:false]
  end

  it "false cannot be assigned to" do
    lambda {
      opal_parse "true = 1"
    }.should raise_error(Exception)
  end

  it "parses nil keyword" do
    opal_parse("nil").should == [:nil]
  end

  it "nil cannot be assigned to" do
    lambda {
      opal_parse "nil = 1"
    }.should raise_error(Exception)
  end

  it "parses self keyword" do
    opal_parse("self").should == [:self]
  end

  it "self cannot be assigned to" do
    lambda {
      opal_parse "self = 1"
    }.should raise_error(Exception)
  end

  it "parses __FILE__ and should always return a s(:str) with given parser filename" do
    opal_parse("__FILE__", "foo").should == [:str, "foo"]
  end

  it "parses __LINE__ and should always return a literal number of the current line" do
    opal_parse("__LINE__").should == [:int, 1]
    opal_parse("\n__LINE__").should == [:int, 2]
  end

  it "parses integers as a s(:int) sexp" do
    opal_parse("32").should == [:int, 32]
  end

  it "parses floats as a s(:float)" do
    opal_parse("3.142").should == [:float, 3.142]
  end

  describe "parsing arrays" do
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

  describe "parsing hashes" do
    it "without any assocs should return an empty hash sexp" do
      opal_parse("{}").should == [:hash]
    end

    it "adds each assoc pair as individual args onto sexp" do
      opal_parse("{1 => 2}").should == [:hash, [:int, 1], [:int, 2]]
      opal_parse("{1 => 2, 3 => 4}").should == [:hash, [:int, 1], [:int, 2], [:int, 3], [:int, 4]]
    end

    it "supports 1.9 style hash keys" do
      opal_parse("{ a: 1 }").should == [:hash, [:sym, :a], [:int, 1]]
      opal_parse("{ a: 1, b: 2 }").should == [:hash, [:sym, :a], [:int, 1], [:sym, :b], [:int, 2]]
    end
  end

  describe "parsing regexps" do
    it "parses a regexp as a s(:lit)" do
      opal_parse("/lol/").should == [:regexp, /lol/]
    end

    it "parses regexp options" do
      opal_parse("/lol/i").should == [:regexp, /lol/i]
    end

    it "can parse regexps using %r notation" do
      opal_parse('%r(foo)').should == [:regexp, /foo/]
      opal_parse('%r(foo)i').should == [:regexp, /foo/i]
    end
  end
end
