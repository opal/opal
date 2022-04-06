require 'spec_helper'

describe "Symbol#to_proc" do
  # bug #2417
  it "correctly passes method name to #method_missing" do
    obj = Object.new
    def obj.method_missing(*args); args; end;
    result = :a.to_proc.call(obj, 6, 7)
    result.should == [:a, 6, 7]
  end

  it "correctly passes a block to #method_missing" do
    obj = Object.new
    block = ->{}
    def obj.method_missing(*args, &block); block; end;
    result = :a.to_proc.call(obj, 1, 2, 3, &block)
    result.should == block
  end
end
