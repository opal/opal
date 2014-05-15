require 'support/parser_helpers'

describe "Iters" do
  describe "Iter on a command" do
    it "the outer command call gets the iter" do
      expect(parsed("a b do; end")).to eq([:call, nil, :a, [:arglist, [:call, nil, :b, [:arglist]]], [:iter, nil]])
      expect(parsed("a 1, b do; end")).to eq([:call, nil, :a, [:arglist, [:int, 1], [:call, nil, :b, [:arglist]]], [:iter, nil]])
    end
  end

  describe "with no args" do
    it "has 'nil' as the args part of sexp" do
      expect(parsed("proc do; end")[4][1]).to eq(nil)
    end
  end

  describe "with empty || args" do
    it "should have args set to nil" do
      expect(parsed("proc do ||; end")[4][1]).to eq(nil)
    end
  end

  describe "with normal args" do
    it "adds a single s(:lasgn) for 1 norm arg" do
      expect(parsed("proc do |a|; end")[4][1]).to eq([:lasgn, :a])
    end

    it "lists multiple norm args inside a s(:masgn)" do
      expect(parsed("proc do |a, b|; end")[4][1]).to eq([:masgn, [:array, [:lasgn, :a], [:lasgn, :b]]])
      expect(parsed("proc do |a, b, c|; end")[4][1]).to eq([:masgn, [:array, [:lasgn, :a], [:lasgn, :b], [:lasgn, :c]]])
    end
  end

  describe "with splat arg" do
    it "adds a s(:masgn) for the s(:splat) even if its the only arg" do
      expect(parsed("proc do |*a|; end")[4][1]).to eq([:masgn, [:array, [:splat, [:lasgn, :a]]]])
      expect(parsed("proc do |a, *b|; end")[4][1]).to eq([:masgn, [:array, [:lasgn, :a], [:splat, [:lasgn, :b]]]])
    end
  end

  describe "with opt args" do
    it "adds a s(:block) arg to end of s(:masgn) for each lasgn" do
      expect(parsed("proc do |a = 1|; end")[4][1]).to eq([:masgn, [:array, [:lasgn, :a], [:block, [:lasgn, :a, [:int, 1]]]]])
      expect(parsed("proc do |a = 1, b = 2|; end")[4][1]).to eq([:masgn, [:array, [:lasgn, :a], [:lasgn, :b], [:block, [:lasgn, :a, [:int, 1]], [:lasgn, :b, [:int, 2]]]]])
    end

    it "should add lasgn block after all other args" do
      expect(parsed("proc do |a, b = 1|; end")[4][1]).to eq([:masgn, [:array, [:lasgn, :a], [:lasgn, :b], [:block, [:lasgn, :b, [:int, 1]]]]])
      expect(parsed("proc do |b = 1, *c|; end")[4][1]).to eq([:masgn, [:array, [:lasgn, :b], [:splat, [:lasgn, :c]], [:block, [:lasgn, :b, [:int, 1]]]]])
      expect(parsed("proc do |b = 1, &c|; end")[4][1]).to eq([:masgn, [:array, [:lasgn, :b], [:block_pass, [:lasgn, :c]], [:block, [:lasgn, :b, [:int, 1]]]]])
    end
  end

  describe "with block arg" do
    it "should add block arg with s(:block_pass) wrapping s(:lasgn) prefix" do
      expect(parsed("proc do |&a|; end")[4][1]).to eq([:masgn, [:array, [:block_pass, [:lasgn, :a]]]])
    end
  end
end
