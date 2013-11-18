require 'spec_helper'

describe "Blocks" do
  it "accept default arguments" do
    proc { |a, b = 100| [a, b] }.call(:foo, :bar).should == [:foo, :bar]
    proc { |a, b = 100| [a, b] }.call(:foo).should == [:foo, 100]
  end

  it "the block variable can be optionally overwritten without destroying original block reference" do
    klass = Class.new { def foo(&block); block = 100 if false; block; end }
    klass.new.foo {}.should be_kind_of(Proc)
  end

  it "can accept a block" do
    proc { |&b| b }.call(&:to_s).should be_kind_of(Proc)
  end

  it "does not cache block between invocations" do
    p = proc { |&b| b }
    p.call(&:to_s).should be_kind_of(Proc)
    p.call.should be_nil
  end
end
