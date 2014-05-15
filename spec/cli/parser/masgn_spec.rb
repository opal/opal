require 'support/parser_helpers'

describe "Masgn" do
  describe "with a single lhs splat" do
    it "returns a s(:masgn)" do
      expect(parsed('*a = 1, 2').first).to eq(:masgn)
      expect(parsed('* = 1, 2').first).to eq(:masgn)
    end

    it "wraps splat inside a s(:array)" do
      expect(parsed('*a = 1, 2')[1]).to eq([:array, [:splat, [:lasgn, :a]]])
      expect(parsed('* = 1, 2')[1]).to eq([:array, [:splat]])
    end
  end

  describe "with more than 1 lhs item" do
    it "returns a s(:masgn) " do
      expect(parsed('a, b = 1, 2').first).to eq(:masgn)
    end

    it "collects all lhs args into an s(:array)" do
      expect(parsed('a, b = 1, 2')[1]).to eq([:array, [:lasgn, :a], [:lasgn, :b]])
      expect(parsed('@a, @b = 1, 2')[1]).to eq([:array, [:iasgn, :@a], [:iasgn, :@b]])
    end

    it "supports splat parts" do
      expect(parsed('a, *b = 1, 2')[1]).to eq([:array, [:lasgn, :a], [:splat, [:lasgn, :b]]])
      expect(parsed('@a, * = 1, 2')[1]).to eq([:array, [:iasgn, :@a], [:splat]])
    end
  end

  describe "with a single rhs argument" do
    it "should wrap rhs in an s(:to_ary)" do
      expect(parsed('a, b = 1')[2]).to eq([:to_ary, [:int, 1]])
    end
  end
end
