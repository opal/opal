require 'support/parser_helpers'

describe Opal::Parser do

  it "parses true keyword" do
    parsed("true").should == [:true]
  end

  it "true cannot be assigned to" do
    lambda {
      parsed "true = 1"
    }.should raise_error(Exception)
  end

  it "parses false keyword" do
    parsed("false").should == [:false]
  end

  it "false cannot be assigned to" do
    lambda {
      parsed "true = 1"
    }.should raise_error(Exception)
  end

  it "parses nil keyword" do
    parsed("nil").should == [:nil]
  end

  it "nil cannot be assigned to" do
    lambda {
      parsed "nil = 1"
    }.should raise_error(Exception)
  end

  it "parses self keyword" do
    parsed("self").should == [:self]
  end

  it "self cannot be assigned to" do
    lambda {
      parsed "self = 1"
    }.should raise_error(Exception)
  end

  it "parses __FILE__ and should always return a s(:str) with given parser filename" do
    parsed("__FILE__", "foo").should == [:str, "foo"]
  end

  it "parses __LINE__ and should always return a literal number of the current line" do
    parsed("__LINE__").should == [:int, 1]
    parsed("\n__LINE__").should == [:int, 2]
  end

  it "parses integers as a s(:int) sexp" do
    parsed("32").should == [:int, 32]
  end

  it "parses integers as a s(:int) sexp" do
    parsed("0b1111_1111_1111").should == [:int, 4095]
  end

  it "parses integers as a s(:int) sexp" do
    parsed("9007199254740991").should == [:int, 9007199254740991]
    parsed("-9007199254740991").should == [:int, -9007199254740991]
  end

  it "parses bignum as Bignum-object creation" do
    parsed("9007199254740992").should == [:bignum, "9007199254740992"]
    parsed("-9007199254740992").should == [:bignum, "-9007199254740992"]
  end

  it "parses bignum as Bignum-object creation" do
    parsed("0x8000_0000_0000_0000").should == 
      [:bignum, "9223372036854775808"]
    parsed("-0x8000_0000_0000_0000").should == 
      [:bignum, "-9223372036854775808"]
  end

  it "parses bignum as Bignum-object creation" do
    parsed("0b1111111111111111111111111111111111111111111111111111111111111111")
      .should == [:bignum, "18446744073709551615"]
    parsed("-0b1111111111111111111111111111111111111111111111111111111111111111")
      .should == [:bignum, "-18446744073709551615"]
  end

  it "parses bignum as Bignum-object creation" do
    parsed("0o7777777777777777777777")
      .should == [:bignum, "73786976294838206463"]
    parsed("-0o7777777777777777777777")
      .should == [:bignum, "-73786976294838206463"]
  end

  it "parses bignum as Bignum-object creation" do
    parsed("0d9999999999999999999999")
      .should == [:bignum, "9999999999999999999999"]
    parsed("-0d9999999999999999999999")
      .should == [:bignum, "-9999999999999999999999"]
  end

  it "parses floats as a s(:float)" do
    parsed("3.142").should == [:float, 3.142]
  end

  describe "parsing arrays" do
    it "should parse empty arrays as s(:array)" do
      parsed("[]").should == [:array]
    end

    it "should append regular args onto end of array sexp" do
      parsed("[1]").should == [:array, [:int, 1]]
      parsed("[1, 2]").should == [:array, [:int, 1], [:int, 2]]
      parsed("[1, 2, 3]").should == [:array, [:int, 1], [:int, 2], [:int, 3]]
    end

    it "should return a single item s(:array) with given splat if no norm args" do
      parsed("[*1]").should == [:array, [:splat, [:int, 1]]]
    end

    it "should allow splats combined with any number of norm args" do
      parsed("[1, *2]").should == [:array, [:int, 1], [:splat, [:int, 2]]]
      parsed("[1, 2, *3]").should == [:array, [:int, 1], [:int, 2], [:splat, [:int, 3]]]
    end
  end

  describe "parsing hashes" do
    it "without any assocs should return an empty hash sexp" do
      parsed("{}").should == [:hash]
    end

    it "adds each assoc pair as individual args onto sexp" do
      parsed("{1 => 2}").should == [:hash, [:int, 1], [:int, 2]]
      parsed("{1 => 2, 3 => 4}").should == [:hash, [:int, 1], [:int, 2], [:int, 3], [:int, 4]]
    end

    it "supports 1.9 style hash keys" do
      parsed("{ a: 1 }").should == [:hash, [:sym, :a], [:int, 1]]
      parsed("{ a: 1, b: 2 }").should == [:hash, [:sym, :a], [:int, 1], [:sym, :b], [:int, 2]]
    end

    it "parses hash arrows without spaces around arguments" do
      parsed("{1=>2}").should == [:hash, [:int, 1], [:int, 2]]
      parsed("{:foo=>2}").should == [:hash, [:sym, :foo], [:int, 2]]
    end
  end

  describe "parsing regexps" do
    it "parses a regexp" do
      parsed("/lol/").should == [:regexp, 'lol', nil]
    end

    it "parses regexp options" do
      parsed("/lol/i").should == [:regexp, 'lol', 'i']
    end

    it "can parse regexps using %r notation" do
      parsed('%r(foo)').should == [:regexp, 'foo', nil]
      parsed('%r(foo)i').should == [:regexp, 'foo', 'i']
    end
  end
end
