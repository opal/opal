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

  class A < SingletonMethodSuperSpec
    def passing_block(*a)
      super
    end

    def self.pass_block
      super
    end
  end
end

# FIXME: we cant make a better test case than this??? For some reason, a single test cannot be deduced
describe "The 'super' keyword" do
  it "passes the right arguments when a variable rewrites special `arguments` js object" do
    Struct.new(:a, :b, :c).new(1, 2, 3).b.should == 2
  end

  it "calls super method on object that defines singleton method calling super" do
    obj = SingletonMethodSuperSpec.new
    def obj.meth; "foo " + super; end
    obj.meth.should == "foo bar"
  end

  describe "with no arguments or parens" do
    before do
      @obj = SingletonMethodSuperSpec::A.new
      @kls = SingletonMethodSuperSpec::A
    end

    it "passes the block to super" do
      @obj.passing_block(1, 2, 3).should == [[1, 2, 3], false]
      @obj.passing_block(1, 2, 3) { }.should == [[1, 2, 3], true]
    end

    it "passes the block to super on singleton methods" do
      @kls.pass_block.should be_false
      @kls.pass_block { }.should be_true
    end
  end
end
