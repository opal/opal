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
      specs.fooM0.should == 100
    end

    it "raises ArgumentError if the method has a positive arity" do
      lambda {
        specs.fooM1
      }.should raise_error(ArgumentError)
    end
  end

  describe "with only manditory arguments" do
    it "requires exactly the same number of passed values" do
      specs.fooM1(1).should == [1]
      specs.fooM2(1,2).should == [1,2]
      specs.fooM3(1,2,3).should == [1,2,3]
      specs.fooM4(1,2,3,4).should == [1,2,3,4]
      specs.fooM5(1,2,3,4,5).should == [1,2,3,4,5]
    end

    it "raises ArgumentError if the methods arity doesn't match" do
      lambda {
        specs.fooM1(1,2)
      }.should raise_error(ArgumentError)
    end
  end

  describe "with optional arguments" do
    it "uses the optional argument if none is is passed" do
      specs.fooM0O1.should == [1]
    end

    it "uses the passed argument if available" do
      specs.fooM0O1(2).should == [2]
    end

    it "raises ArgumentError if extra arguments are passed" do
      lambda {
        specs.fooM0O1(2,3)
      }.should raise_error(ArgumentError)
    end
  end

  describe "with manditory and optional arguments" do
    it "uses the passed values in left to right order" do
      specs.fooM1O1(2).should == [2,1]
    end

    it "raises an ArgumentError if there are no values for the manditory args" do
      lambda {
        specs.fooM1O1
      }.should raise_error(ArgumentError)
    end

    it "raises an ArgumentError if too many values are passed" do
      lambda {
        specs.fooM1O1(1,2,3)
      }.should raise_error(ArgumentError)
    end
  end

  describe "with a rest argument" do
    it "is an empty array if there are no additional arguments" do
      specs.fooM0R().should == []
      specs.fooM1R(1).should == [1, []]
    end

    it "gathers unused arguments" do
      specs.fooM0R(1).should == [1]
      specs.fooM1R(1,2).should == [1, [2]]
    end
  end

  it "with a block makes it available to yield" do
    specs.oneb(10) { 200 }.should == [10,200]
  end

  it "with a block converts the block to a Proc" do
    prc = specs.makeproc { "hello" }
    prc.should be_kind_of(Proc)
    prc.call.should == "hello"
  end

  it "with an object as a block uses 'to_proc' for coercion" do
    o = LangSendSpecs::ToProc.new(:from_to_proc)

    specs.makeproc(&o).call.should == :from_to_proc

    specs.yield_now(&o).should == :from_to_proc
  end

  it "raises a SyntaxError with both a literal block and an object as block" do
    lambda {
      eval "specs.oneb(10, &l){ 42 }"
    }.should raise_error(SyntaxError)
  end

  it "with same names as existing variables is ok" do
    foobar = 100

    def foobar; 200; end

    foobar.should == 100
    foobar().should == 200
  end

  it "with splat operator makes the object the direct arguments" do
    a = [1,2,3]
    specs.fooM3(*a).should == [1,2,3]
  end

  it "without parentheses works" do
    (specs.fooM3 1,2,3).should == [1,2,3]
  end

  it "with a space separating method name and parenthesis treats expression in parenthesis as first argument" do
    specs.weird_parens().should == "55"
  end

  ruby_version_is "" ... "1.9" do
    describe "allows []=" do
      before :each do
        @obj = LangSendSpecs::AttrSet.new
      end

      it "with *args in the [] expanded to individual arguments" do
        ary = [2,3]
        (@obj[1, *ary] = 4).should == 4
        @obj.result.should == [1,2,3,4]
      end

      it "with multiple *args" do
        ary = [2,3]
        post = [4,5]
        (@obj[1, *ary] = *post).should == [4,5]
        @obj.result.should == [1,2,3,[4,5]]
      end

      it "with multiple *args and unwraps the last splat" do
        ary = [2,3]
        post = [4]
        (@obj[1, *ary] = *post).should == 4
        @obj.result.should == [1,2,3,4]
      end

      it "with a *args and multiple rhs args" do
        ary = [2,3]
        (@obj[1, *ary] = 4, 5).should == [4,5]
        @obj.result.should == [1,2,3,[4,5]]
      end
    end
  end

  it "passes literal hashes without curly braces as the last parameter" do
    specs.fooM3('abc', 456, 'rbx' => 'cool',
         'specs' => 'fail sometimes', 'oh' => 'weh').should == \
     ['abc', 456, {'rbx' => 'cool', 'specs' => 'fail sometimes', 'oh' => 'weh'}]
  end

  it "passes a literal hash without curly braces or parens" do
    (specs.fooM3 'abc', 456, 'rbx' => 'cool',
        'specs' => 'fail sometimes', 'oh' => 'weh').should == \
     ['abc', 456, { 'rbx' => 'cool', 'specs' => 'fail sometimes', 'oh' => 'weh'}]
  end

  it "allows to literal hashes without curly braces as the only parameter" do
    specs.fooM1(:rbx => :cool, :specs => :fail_sometimes).should ==
      [{ :rbx => :cool, :specs => :fail_sometimes }]

    (specs.fooM1 :rbx => :cool, :specs => :fail_sometimes).should ==
      [{ :rbx => :cool, :specs => :fail_sometimes }]
  end

  describe "when the method is not available" do
    it "invokes method_missing" do
      o = LangSendSpecs::MethodMissing.new
      o.not_there(1,2)
      o.message.should == :not_there
      o.args.should == [1,2]
    end
  end

end

describe "Invoking a private setter method" do
  describe "permits self as a receiver" do
    it "for normal assignment" do
      receiver = LangSendSpecs::PrivateSetter.new
      receiver.call_self_foo_equals(42)
      receiver.foo.should == 42
    end

    it "for multiple assignment" do
      receiver = LangSendSpecs::PrivateSetter.new
      receiver.call_self_foo_equals_masgn(42)
      receiver.foo.should == 42
    end
  end
end

describe "Invoking a private getter method" do
  it "does not permit self as a receiver" do
    receiver = LangSendSpecs::PrivateGetter.new
    lambda { receiver.call_self_foo }.should raise_error(NoMethodError)
    lambda { receiver.call_self_foo_or_equals(6) }.should raise_error(NoMethodError)
  end
end

# language_version __FILE__, "send"
