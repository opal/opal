require 'spec_helper'

describe "Module#define_method" do
  describe "when passed an UnboundMethod object" do
    it "defines a method taking a block" do
      klass = Class.new do
        def foo = yield :bar
      end
      klass.define_method(:baz, klass.instance_method(:foo))
      klass.new.baz { |a| a }.should == :bar
    end
  end
end
