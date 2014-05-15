require 'spec_helper'

class SingletonMethodSuperSpec
  def meth
    "bar"
  end

  def passing_block(*args, &block)
    [args, block_given?]
  end

  def self.pass_block(&block)
    block_given?
  end

  def super_args(*a)
    block_given?
  end

  def self.super_args(*a)
    block_given?
  end

  def with_splat_args(*a)
    a
  end

  class A < SingletonMethodSuperSpec
    def passing_block(*a)
      super
    end

    def self.pass_block
      super
    end

    def super_args(*a)
      super(*a)
    end

    def self.super_args(*a)
      super()
    end

    def with_splat_args
      super 2, *[3, 4]
    end
  end
end

class MultipleSuperSpec
  def to_s
    if true
      super
    else
      super()
    end
  end
end

# FIXME: we cant make a better test case than this??? For some reason, a single test cannot be deduced
describe "The 'super' keyword" do
  it "passes the right arguments when a variable rewrites special `arguments` js object" do
    expect(Struct.new(:a, :b, :c).new(1, 2, 3).b).to eq(2)
  end

  it "calls super method on object that defines singleton method calling super" do
    obj = SingletonMethodSuperSpec.new
    def obj.meth; "foo " + super; end
    expect(obj.meth).to eq("foo bar")
  end

  describe "with no arguments or parens" do
    before do
      @obj = SingletonMethodSuperSpec::A.new
      @kls = SingletonMethodSuperSpec::A
    end

    it "passes the block to super" do
      expect(@obj.passing_block(1, 2, 3)).to eq([[1, 2, 3], false])
      expect(@obj.passing_block(1, 2, 3) { }).to eq([[1, 2, 3], true])
    end

    it "passes the block to super on singleton methods" do
      expect(@kls.pass_block).to be_false
      expect(@kls.pass_block { }).to be_true
    end
  end

  describe "with arguments or empty parens" do
    before do
      @obj = SingletonMethodSuperSpec::A.new
      @kls = SingletonMethodSuperSpec::A
    end

    it "does not pass the block to super" do
      expect(@obj.super_args(1, 2, 3) { }).to be_false
      expect(@kls.super_args() { }).to be_false
    end
  end

  it "handles splat args" do
    expect(SingletonMethodSuperSpec::A.new.with_splat_args).to eq([2, 3, 4])
  end

  describe "inside a class body" do
    it "does not break when multiple super statements are in body" do
      expect { MultipleSuperSpec.new.to_s }.not_to raise_error
    end
  end
end


module OpalSuperSpecs
  class A
    def foo
      'a'
    end

    def self.bar
      'x'
    end
  end

  class B < A
    def foo
      super + 'b'
    end

    def self.bar
      super + 'y'
    end
  end

  class C < B
    def foo
      super + 'c'
    end

    def self.bar
      super + 'z'
    end
  end

  module M1
    def chain(out)
      out << 'M1'
    end
  end

  module M2
    def chain(out)
      out << 'M2'
      super out
    end
  end

  module M3
    def chain(out)
      out << 'M3'
      super out
    end
  end

  class C1
    include M1
    include M2
    include M3
  end

  class C2
    include M1
    include M2

    def chain(out)
      out << 'C2'
      super out
    end
  end

  class C3
    def chain(out)
      out << 'C3'
    end
  end

  class C4 < C3
    include M2
  end
end

describe "Super chains" do
  it "searches entire class hierarchys for instance methods" do
    expect(OpalSuperSpecs::C.new.foo).to eq('abc')
  end

  it "searches entire class hierarchys for class methods" do
    expect(OpalSuperSpecs::C.bar).to eq('xyz')
  end

  it "calls methods for every module included in a class" do
    expect(OpalSuperSpecs::C1.new.chain([])).to eq(['M3', 'M2', 'M1'])
  end

  it "calls method defined in class before modules" do
    expect(OpalSuperSpecs::C2.new.chain([])).to eq(['C2', 'M2', 'M1'])
  end

  it "calls method defined on superclass after modules included by child" do
    expect(OpalSuperSpecs::C4.new.chain([])).to eq(['M2', 'C3'])
  end
end
