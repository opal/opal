require 'support/parser_helpers'

describe "Lambda literals" do
  it "should parse with either do/end construct or curly braces" do
    expect(parsed("-> {}").first).to eq(:call)
    expect(parsed("-> do; end").first).to eq(:call)
  end

  it "should parse as a call to 'lambda' with the lambda body as a block" do
    expect(parsed("-> {}")).to eq([:call, nil, :lambda, [:arglist], [:iter, nil]])
  end

  describe "with no args" do
    it "should accept no args" do
      expect(parsed("-> {}")[4][1]).to eq(nil)
    end
  end

  describe "with normal args" do
    it "adds a single s(:lasgn) for 1 norm arg" do
      expect(parsed("->(a) {}")[4][1]).to eq([:lasgn, :a])
    end

    it "lists multiple norm args inside a s(:masgn)" do
      expect(parsed("-> (a, b) {}")[4][1]).to eq([:masgn, [:array, [:lasgn, :a], [:lasgn, :b]]])
      expect(parsed("-> (a, b, c) {}")[4][1]).to eq([:masgn, [:array, [:lasgn, :a], [:lasgn, :b], [:lasgn, :c]]])
    end
  end

  describe "with optional braces" do
    it "parses normal args" do
      expect(parsed("-> a {}")[4][1]).to eq([:lasgn, :a])
      expect(parsed("-> a, b {}")[4][1]).to eq([:masgn, [:array, [:lasgn, :a], [:lasgn, :b]]])
    end

    it "parses splat args" do
      expect(parsed("-> *a {}")[4][1]).to eq([:masgn, [:array, [:splat, [:lasgn, :a]]]])
      expect(parsed("-> a, *b {}")[4][1]).to eq([:masgn, [:array, [:lasgn, :a], [:splat, [:lasgn, :b]]]])
    end

    it "parses opt args" do
      expect(parsed("-> a = 1 {}")[4][1]).to eq([:masgn, [:array, [:lasgn, :a], [:block, [:lasgn, :a, [:int, 1]]]]])
      expect(parsed("-> a = 1, b = 2 {}")[4][1]).to eq([:masgn, [:array, [:lasgn, :a], [:lasgn, :b], [:block, [:lasgn, :a, [:int, 1]], [:lasgn, :b, [:int, 2]]]]])
    end

    it "parses block args" do
      expect(parsed("-> &a {}")[4][1]).to eq([:masgn, [:array, [:block_pass, [:lasgn, :a]]]])
    end
  end

  describe "with body statements" do
    it "should be nil when no statements given" do
      expect(parsed("-> {}")[4][2]).to eq(nil)
    end

    it "should be the single sexp when given one statement" do
      expect(parsed("-> { 42 }")[4][2]).to eq([:int, 42])
    end

    it "should wrap multiple statements into a s(:block)" do
      expect(parsed("-> { 42; 3.142 }")[4][2]).to eq([:block, [:int, 42], [:float, 3.142]])
    end
  end
end
