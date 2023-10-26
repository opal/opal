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

  describe "when called inside a def" do
    it "returns correctly" do
      klass = Class.new do
        def self.my_method_definer
          define_method(:a) do
            return :foo
            :bar
          end
        end
      end

      klass.my_method_definer
      klass.new.a.should == :foo
    end
  end
end
