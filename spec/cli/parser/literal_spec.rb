require 'support/parser_helpers'

describe Opal::Parser do

  it "parses true keyword" do
    expect(parsed("true")).to eq([:true])
  end

  it "true cannot be assigned to" do
    expect {
      parsed "true = 1"
    }.to raise_error(Exception)
  end

  it "parses false keyword" do
    expect(parsed("false")).to eq([:false])
  end

  it "false cannot be assigned to" do
    expect {
      parsed "true = 1"
    }.to raise_error(Exception)
  end

  it "parses nil keyword" do
    expect(parsed("nil")).to eq([:nil])
  end

  it "nil cannot be assigned to" do
    expect {
      parsed "nil = 1"
    }.to raise_error(Exception)
  end

  it "parses self keyword" do
    expect(parsed("self")).to eq([:self])
  end

  it "self cannot be assigned to" do
    expect {
      parsed "self = 1"
    }.to raise_error(Exception)
  end

  it "parses __FILE__ and should always return a s(:str) with given parser filename" do
    expect(parsed("__FILE__", "foo")).to eq([:str, "foo"])
  end

  it "parses __LINE__ and should always return a literal number of the current line" do
    expect(parsed("__LINE__")).to eq([:int, 1])
    expect(parsed("\n__LINE__")).to eq([:int, 2])
  end

  it "parses integers as a s(:int) sexp" do
    expect(parsed("32")).to eq([:int, 32])
  end

  it "parses floats as a s(:float)" do
    expect(parsed("3.142")).to eq([:float, 3.142])
  end

  describe "parsing arrays" do
    it "should parse empty arrays as s(:array)" do
      expect(parsed("[]")).to eq([:array])
    end

    it "should append regular args onto end of array sexp" do
      expect(parsed("[1]")).to eq([:array, [:int, 1]])
      expect(parsed("[1, 2]")).to eq([:array, [:int, 1], [:int, 2]])
      expect(parsed("[1, 2, 3]")).to eq([:array, [:int, 1], [:int, 2], [:int, 3]])
    end

    it "should return a single item s(:array) with given splat if no norm args" do
      expect(parsed("[*1]")).to eq([:array, [:splat, [:int, 1]]])
    end

    it "should allow splats combined with any number of norm args" do
      expect(parsed("[1, *2]")).to eq([:array, [:int, 1], [:splat, [:int, 2]]])
      expect(parsed("[1, 2, *3]")).to eq([:array, [:int, 1], [:int, 2], [:splat, [:int, 3]]])
    end
  end

  describe "parsing hashes" do
    it "without any assocs should return an empty hash sexp" do
      expect(parsed("{}")).to eq([:hash])
    end

    it "adds each assoc pair as individual args onto sexp" do
      expect(parsed("{1 => 2}")).to eq([:hash, [:int, 1], [:int, 2]])
      expect(parsed("{1 => 2, 3 => 4}")).to eq([:hash, [:int, 1], [:int, 2], [:int, 3], [:int, 4]])
    end

    it "supports 1.9 style hash keys" do
      expect(parsed("{ a: 1 }")).to eq([:hash, [:sym, :a], [:int, 1]])
      expect(parsed("{ a: 1, b: 2 }")).to eq([:hash, [:sym, :a], [:int, 1], [:sym, :b], [:int, 2]])
    end

    it "parses hash arrows without spaces around arguments" do
      expect(parsed("{1=>2}")).to eq([:hash, [:int, 1], [:int, 2]])
      expect(parsed("{:foo=>2}")).to eq([:hash, [:sym, :foo], [:int, 2]])
    end
  end

  describe "parsing regexps" do
    it "parses a regexp" do
      expect(parsed("/lol/")).to eq([:regexp, 'lol', nil])
    end

    it "parses regexp options" do
      expect(parsed("/lol/i")).to eq([:regexp, 'lol', 'i'])
    end

    it "can parse regexps using %r notation" do
      expect(parsed('%r(foo)')).to eq([:regexp, 'foo', nil])
      expect(parsed('%r(foo)i')).to eq([:regexp, 'foo', 'i'])
    end
  end
end
