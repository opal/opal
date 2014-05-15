require 'support/parser_helpers'

describe Opal::Parser do
  it "parses instance variables" do
    expect(parsed("@a")).to eq([:ivar, :@a])
    expect(parsed("@A")).to eq([:ivar, :@A])
    expect(parsed("@class")).to eq([:ivar, :@class])
  end

  it "parses instance variable assignment" do
    expect(parsed("@a = 1")).to eq([:iasgn, :@a, [:int, 1]])
    expect(parsed("@A = 1")).to eq([:iasgn, :@A, [:int, 1]])
    expect(parsed("@class = 1")).to eq([:iasgn, :@class, [:int, 1]])
  end

  describe "parses local variables" do
    it "should be created when an identifier is previously assigned to" do
      expect(parsed("a = 1; a")).to eq([:block, [:lasgn, :a, [:int, 1]], [:lvar, :a]])
      expect(parsed("a = 1; a; a")).to eq([:block, [:lasgn, :a, [:int, 1]], [:lvar, :a], [:lvar, :a]])
    end

    it "should not be created when no lasgn is previously used on name" do
      expect(parsed("a")).to eq([:call, nil, :a, [:arglist]])
      expect(parsed("a = 1; b")).to eq([:block, [:lasgn, :a, [:int, 1]], [:call, nil, :b, [:arglist]]])
    end
  end

  describe "parses local variables inside a def" do
    it "should created by a norm arg" do
      expect(parsed("def a(b); b; end")).to eq([:def, nil, :a, [:args, :b], [:block, [:lvar, :b]]])
      expect(parsed("def a(b, c); c; end")).to eq([:def, nil, :a, [:args, :b, :c], [:block, [:lvar, :c]]])
    end

    it "should be created by an opt arg" do
      expect(parsed("def a(b=10); b; end")).to eq([:def, nil, :a, [:args, :b, [:block, [:lasgn, :b, [:int, 10]]]], [:block, [:lvar, :b]]])
    end

    it "should be created by a rest arg" do
      expect(parsed("def a(*b); b; end")).to eq([:def, nil, :a, [:args, :"*b"], [:block, [:lvar, :b]]])
    end

    it "should be created by a block arg" do
      expect(parsed("def a(&b); b; end")).to eq([:def, nil, :a, [:args, :"&b"], [:block, [:lvar, :b]]])
    end

    it "should not be created from locals outside the def" do
      expect(parsed("a = 10; def b; a; end")).to eq([:block, [:lasgn, :a, [:int, 10]], [:def, nil, :b, [:args], [:block, [:call, nil, :a, [:arglist]]]]])
    end
  end

  it "parses local var assignment" do
    expect(parsed("a = 1")).to eq([:lasgn, :a, [:int, 1]])
    expect(parsed("a = 1; b = 2")).to eq([:block, [:lasgn, :a, [:int, 1]], [:lasgn, :b, [:int, 2]]])
  end

  it "parses class variables" do
    expect(parsed("@@foo")).to eq([:cvar, :@@foo])
  end

  it "parses class variable assignment" do
    expect(parsed("@@foo = 100")).to eq([:cvdecl, :@@foo, [:int, 100]])
  end

  it "parses global variables" do
    expect(parsed("$foo")).to eq([:gvar, :$foo])
    expect(parsed("$:")).to eq([:gvar, :$:])
  end

  it "parses global var assignment" do
    expect(parsed("$foo = 1")).to eq([:gasgn, :$foo, [:int, 1]])
    expect(parsed("$: = 1")).to eq([:gasgn, :$:, [:int, 1]])
  end

  it "parses as s(:nth_ref)" do
    expect(parsed('$1').first).to eq(:nth_ref)
  end

  it "references the number 1..9 as first part" do
    expect(parsed('$1')).to eq([:nth_ref, '1'])
    expect(parsed('$9')).to eq([:nth_ref, '9'])
  end

  it "parses constants" do
    expect(parsed("FOO")).to eq([:const, :FOO])
    expect(parsed("BAR")).to eq([:const, :BAR])
  end

  it "parses constant assignment" do
    expect(parsed("FOO = 1")).to eq([:cdecl, :FOO, [:int, 1]])
    expect(parsed("FOO = BAR")).to eq([:cdecl, :FOO, [:const, :BAR]])
  end
end
