require "spec_helper"

module MethodMissingSpecs
  class A
    def method_missing(mid, *args)
      [mid, args]
    end
  end

  class B
    def method_missing(mid, *args, &block)
      [mid, block]
    end
  end
end

describe "method_missing" do
  before do
    @obj = MethodMissingSpecs::A.new
  end

  it "should pass the missing method name as first argument" do
    @obj.foo.should == [:foo, []]
  end

  it "should correctly pass arguments to method_missing" do
    @obj.bar(1, 2, 3).should == [:bar, [1, 2, 3]]
  end

  it "should pass blocks to method_missing" do
    obj = MethodMissingSpecs::B.new
    proc = proc { 1 }
    obj.baz(1, 2, &proc).should == [:baz, proc]
  end
end

describe "BasicObject#method_missing" do
  it "raises an error for the missing method" do
    lambda {
      BasicObject.new.foo_bar_baz
    }.should raise_error(Exception)
  end
end
