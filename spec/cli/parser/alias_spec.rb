require 'support/parser_helpers'

describe "The alias keyword" do
  describe "with fitem" do
    it "should return an s(:alias) with s(:sym)" do
      expect(parsed("alias a b")).to eq([:alias, [:sym, :a], [:sym, :b]])
      expect(parsed("alias == equals")).to eq([:alias, [:sym, :==], [:sym, :equals]])
    end

    it "should accept symbols as names" do
      expect(parsed("alias :foo :bar")).to eq([:alias, [:sym, :foo], [:sym, :bar]])
    end
  end

  describe "with gvar" do
    it "should return a s(:valias) with two gvars as arguments" do
      expect(parsed("alias $foo $bar")).to eq([:valias, :$foo, :$bar])
    end
  end

  describe "with gvar and nth ref" do
    it "should return a s(:valias) with two values as arguments" do
      expect(parsed("alias $foo $1")).to eq([:valias, :$foo, :"1"])
    end
  end
end
