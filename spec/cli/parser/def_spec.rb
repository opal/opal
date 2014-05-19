require 'support/parser_helpers'

describe "The def keyword" do
  describe "for normal definitions" do
    it "should return s(:def)" do
      expect(parsed("def a; end")).to eq([:def, nil, :a, [:args], [:block, [:nil]]])
    end

    it "adds s(:nil) on an empty body" do
      expect(parsed("def foo; end").last).to eq([:block, [:nil]])
    end
  end

  describe "for singleton definitions" do
    it "should return s(:def)" do
      expect(parsed("def self.a; end")).to eq([:def, [:self], :a, [:args], [:block, [:nil]]])
    end

    it "adds s(:nil) on an empty body" do
      expect(parsed("def self.foo; end").last).to eq([:block, [:nil]])
    end
  end

  describe "with normal args" do
    it "should list all args" do
      expect(parsed("def foo(a); end")[3]).to eq([:args, :a])
      expect(parsed("def foo(a, b); end")[3]).to eq([:args, :a, :b])
      expect(parsed("def foo(a, b, c); end")[3]).to eq([:args, :a, :b, :c])
    end
  end

  describe "with opt args" do
    it "should list all opt args as well as block with each lasgn" do
      expect(parsed("def foo(a = 1); end")[3]).to eq([:args, :a, [:block, [:lasgn, :a, [:int, 1]]]])
      expect(parsed("def foo(a = 1, b = 2); end")[3]).to eq([:args, :a, :b, [:block, [:lasgn, :a, [:int, 1]], [:lasgn, :b, [:int, 2]]]])
    end

    it "should list lasgn block after all other args" do
      expect(parsed("def foo(a, b = 1); end")[3]).to eq([:args, :a, :b, [:block, [:lasgn, :b, [:int, 1]]]])
      expect(parsed("def foo(b = 1, *c); end")[3]).to eq([:args, :b, :"*c", [:block, [:lasgn, :b, [:int, 1]]]])
      expect(parsed("def foo(b = 1, &block); end")[3]).to eq([:args, :b, :"&block", [:block, [:lasgn, :b, [:int, 1]]]])
    end
  end

  describe "with rest args" do
    it "should list rest args in place as a symbol with '*' prefix" do
      expect(parsed("def foo(*a); end")[3]).to eq([:args, :"*a"])
    end

    it "uses '*' as an arg name for rest args without a name" do
      expect(parsed("def foo(*); end")[3]).to eq([:args, :"*"])
    end
  end

  describe "with block arg" do
    it "should list block argument with the '&' prefix" do
      expect(parsed("def foo(&a); end")[3]).to eq([:args, :"&a"])
    end
  end
end

