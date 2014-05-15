require File.expand_path('../fixtures/send', __FILE__)

# Why so many fixed arg tests?  JRuby and I assume other Ruby impls have
# separate call paths for simple fixed arity methods.  Testing up to five
# will verify special and generic arity code paths for all impls.
#
# Method naming conventions:
# M - Manditory Args
# O - Optional Arg
# R - Rest Arg
# Q - Post Manditory Args (1.9)

specs = LangSendSpecs

describe "Invoking a method" do
  describe "with zero arguments" do
    it "requires no arguments passed" do
      expect(specs.fooM0).to eq(100)
    end

    it "raises ArgumentError if the method has a positive arity" do
      expect {
        specs.fooM1
      }.to raise_error(ArgumentError)
    end
  end

  describe "with only manditory arguments" do
    it "requires exactly the same number of passed values" do
      expect(specs.fooM1(1)).to eq([1])
      expect(specs.fooM2(1,2)).to eq([1,2])
      expect(specs.fooM3(1,2,3)).to eq([1,2,3])
      expect(specs.fooM4(1,2,3,4)).to eq([1,2,3,4])
      expect(specs.fooM5(1,2,3,4,5)).to eq([1,2,3,4,5])
    end

    it "raises ArgumentError if the methods arity doesn't match" do
      expect {
        specs.fooM1(1,2)
      }.to raise_error(ArgumentError)
    end
  end

  describe "with optional arguments" do
    it "uses the optional argument if none is is passed" do
      expect(specs.fooM0O1).to eq([1])
    end

    it "uses the passed argument if available" do
      expect(specs.fooM0O1(2)).to eq([2])
    end

    it "raises ArgumentError if extra arguments are passed" do
      expect {
        specs.fooM0O1(2,3)
      }.to raise_error(ArgumentError)
    end
  end

  describe "with manditory and optional arguments" do
    it "uses the passed values in left to right order" do
      expect(specs.fooM1O1(2)).to eq([2,1])
    end

    it "raises an ArgumentError if there are no values for the manditory args" do
      expect {
        specs.fooM1O1
      }.to raise_error(ArgumentError)
    end

    it "raises an ArgumentError if too many values are passed" do
      expect {
        specs.fooM1O1(1,2,3)
      }.to raise_error(ArgumentError)
    end
  end

  describe "with a rest argument" do
    it "is an empty array if there are no additional arguments" do
      expect(specs.fooM0R()).to eq([])
      expect(specs.fooM1R(1)).to eq([1, []])
    end

    it "gathers unused arguments" do
      expect(specs.fooM0R(1)).to eq([1])
      expect(specs.fooM1R(1,2)).to eq([1, [2]])
    end
  end

  it "with a block makes it available to yield" do
    expect(specs.oneb(10) { 200 }).to eq([10,200])
  end

  it "with a block converts the block to a Proc" do
    prc = specs.makeproc { "hello" }
    expect(prc).to be_kind_of(Proc)
    expect(prc.call).to eq("hello")
  end

  it "with an object as a block uses 'to_proc' for coercion" do
    o = LangSendSpecs::ToProc.new(:from_to_proc)

    expect(specs.makeproc(&o).call).to eq(:from_to_proc)

    expect(specs.yield_now(&o)).to eq(:from_to_proc)
  end

  it "raises a SyntaxError with both a literal block and an object as block" do
    expect {
      eval "specs.oneb(10, &l){ 42 }"
    }.to raise_error(SyntaxError)
  end

  it "with same names as existing variables is ok" do
    foobar = 100

    def foobar; 200; end

    expect(foobar).to eq(100)
    expect(foobar()).to eq(200)
  end

  it "with splat operator makes the object the direct arguments" do
    a = [1,2,3]
    expect(specs.fooM3(*a)).to eq([1,2,3])
  end

  it "without parentheses works" do
    expect(specs.fooM3 1,2,3).to eq([1,2,3])
  end

  it "with a space separating method name and parenthesis treats expression in parenthesis as first argument" do
    expect(specs.weird_parens()).to eq("55")
  end

  ruby_version_is "" ... "1.9" do
    describe "allows []=" do
      before :each do
        @obj = LangSendSpecs::AttrSet.new
      end

      it "with *args in the [] expanded to individual arguments" do
        ary = [2,3]
        expect(@obj[1, *ary] = 4).to eq(4)
        expect(@obj.result).to eq([1,2,3,4])
      end

      it "with multiple *args" do
        ary = [2,3]
        post = [4,5]
        expect(@obj[1, *ary] = *post).to eq([4,5])
        expect(@obj.result).to eq([1,2,3,[4,5]])
      end

      it "with multiple *args and unwraps the last splat" do
        ary = [2,3]
        post = [4]
        expect(@obj[1, *ary] = *post).to eq(4)
        expect(@obj.result).to eq([1,2,3,4])
      end

      it "with a *args and multiple rhs args" do
        ary = [2,3]
        expect(@obj[1, *ary] = 4, 5).to eq([4,5])
        expect(@obj.result).to eq([1,2,3,[4,5]])
      end
    end
  end

  it "passes literal hashes without curly braces as the last parameter" do
    expect(specs.fooM3('abc', 456, 'rbx' => 'cool',
         'specs' => 'fail sometimes', 'oh' => 'weh')).to eq( \
     ['abc', 456, {'rbx' => 'cool', 'specs' => 'fail sometimes', 'oh' => 'weh'}]
    )
  end

  it "passes a literal hash without curly braces or parens" do
    expect(specs.fooM3 'abc', 456, 'rbx' => 'cool',
        'specs' => 'fail sometimes', 'oh' => 'weh').to eq( \
     ['abc', 456, { 'rbx' => 'cool', 'specs' => 'fail sometimes', 'oh' => 'weh'}]
    )
  end

  it "allows to literal hashes without curly braces as the only parameter" do
    expect(specs.fooM1(:rbx => :cool, :specs => :fail_sometimes)).to eq(
      [{ :rbx => :cool, :specs => :fail_sometimes }]
    )

    expect(specs.fooM1 :rbx => :cool, :specs => :fail_sometimes).to eq(
      [{ :rbx => :cool, :specs => :fail_sometimes }]
    )
  end

  describe "when the method is not available" do
    it "invokes method_missing" do
      o = LangSendSpecs::MethodMissing.new
      o.not_there(1,2)
      expect(o.message).to eq(:not_there)
      expect(o.args).to eq([1,2])
    end
  end

end

describe "Invoking a private setter method" do
  describe "permits self as a receiver" do
    it "for normal assignment" do
      receiver = LangSendSpecs::PrivateSetter.new
      receiver.call_self_foo_equals(42)
      expect(receiver.foo).to eq(42)
    end

    it "for multiple assignment" do
      receiver = LangSendSpecs::PrivateSetter.new
      receiver.call_self_foo_equals_masgn(42)
      expect(receiver.foo).to eq(42)
    end
  end
end

describe "Invoking a private getter method" do
  it "does not permit self as a receiver" do
    receiver = LangSendSpecs::PrivateGetter.new
    expect { receiver.call_self_foo }.to raise_error(NoMethodError)
    expect { receiver.call_self_foo_or_equals(6) }.to raise_error(NoMethodError)
  end
end

# language_version __FILE__, "send"
