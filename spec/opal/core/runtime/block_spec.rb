require 'spec_helper'

describe "Blocks" do
  it "accept default arguments" do
    expect(proc { |a, b = 100| [a, b] }.call(:foo, :bar)).to eq([:foo, :bar])
    expect(proc { |a, b = 100| [a, b] }.call(:foo)).to eq([:foo, 100])
  end

  it "the block variable can be optionally overwritten without destroying original block reference" do
    klass = Class.new { def foo(&block); block = 100 if false; block; end }
    expect(klass.new.foo {}).to be_kind_of(Proc)
  end

  it "can accept a block" do
    expect(proc { |&b| b }.call(&:to_s)).to be_kind_of(Proc)
  end

  it "does not cache block between invocations" do
    p = proc { |&b| b }
    expect(p.call(&:to_s)).to be_kind_of(Proc)
    expect(p.call).to be_nil
  end
end
