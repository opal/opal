require File.expand_path('../../spec_helper', __FILE__)
require File.expand_path('../fixtures/send', __FILE__)

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
    it "requires exactly thr same number of passed values" do
      specs.fooM1(1).should == [1]
      specs.fooM2(1,2).should == [1,2]
      specs.fooM3(1,2,3).should == [1,2,3]
      specs.fooM4(1,2,3,4).should == [1,2,3,4]
      specs.fooM5(1,2,3,4,5).should == [1,2,3,4,5]
    end
  end

  describe "with optional arguments" do
    it "uses the optional argument if none is is passed" do
      specs.fooM0O1.should == [1]
    end

    it "uses the passed argument if available" do
      specs.fooM0O1(2).should == [2]
    end
  end

  describe "with manditory and optional arguments" do
    it "uses the passed values in left to right order" do
      specs.fooM1O1(2).should == [2, 1]
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

  it "wwith a block converts the block to a Proc" do
    prc = specs.makeproc { "hello" }
    prc.should be_kind_of(Proc)
    prc.call.should == "hello"
  end

  it "with an object as a block used 'to_proc' for coercion" do
    o = LangSendSpecs::ToProc.new(:from_to_proc)

    specs.makeproc(&o).call.should == :from_to_proc

    specs.yield_now(&o).should == :from_to_proc
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

  it "without parantheses works" do
    (specs.fooM3 1,2,3).should == [1,2,3]
  end

  it "passes literal hashes without curly braces as the last parameter" do
    specs.fooM3('abc', 456, 'rbx' => 'cool', 'specs' => 'fail sometimes', 'oh' => 'weh').should == ['abc', 456, {'rbx' => 'cool', 'specs' => 'fail sometimes', 'oh' => 'weh'}]
  end

  it "passes a literal hash without curly braces or parens" do
    (specs.fooM3 'abc', 456, 'rbx' => 'cool', 'specs' => 'fail sometimes', 'oh' => 'weh').should == ['abc', 456, {'rbx' => 'cool', 'specs' => 'fail sometimes', 'oh' => 'weh'}]
  end

  it "allows to literal hashes without curly braces as the only parameter" do
    specs.fooM1(:rbx => :cool, :specs => :fail_sometimes).should == [{ :rbx => :cool, :specs => :fail_sometimes }]
    (specs.fooM1 :rbx => :cool, :specs => :fail_sometimes).should == [{ :rbx => :cool, :specs => :fail_sometimes }]
  end
end
