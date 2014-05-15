require 'support/parser_helpers'

describe "Attribute assignments" do
  it "should return a s(:attrasgn) for simple assignments" do
    expect(parsed('self.foo = 1')).to eq([:attrasgn, [:self], :foo=, [:arglist, [:int, 1]]])
    expect(parsed('bar.foo = 1')).to eq([:attrasgn, [:call, nil, :bar, [:arglist]], :foo=, [:arglist, [:int, 1]]])
    expect(parsed('@bar.foo = 1')).to eq([:attrasgn, [:ivar, :@bar], :foo=, [:arglist, [:int, 1]]])
  end

  it "accepts both '.' and '::' for method call operators" do
    expect(parsed('self.foo = 1')).to eq([:attrasgn, [:self], :foo=, [:arglist, [:int, 1]]])
    expect(parsed('self::foo = 1')).to eq([:attrasgn, [:self], :foo=, [:arglist, [:int, 1]]])
  end

  it "can accept a constant as assignable name when using '.'" do
    expect(parsed('self.FOO = 1')).to eq([:attrasgn, [:self], :FOO=, [:arglist, [:int, 1]]])
  end

  describe "when setting element reference" do
    it "uses []= as the method call" do
      expect(parsed('self[1] = 2')).to eq([:attrasgn, [:self], :[]=, [:arglist, [:int, 1], [:int, 2]]])
    end

    it "supports multiple arguments inside brackets" do
      expect(parsed('self[1, 2] = 3')).to eq([:attrasgn, [:self], :[]=, [:arglist, [:int, 1], [:int, 2], [:int, 3]]])
    end
  end
end
