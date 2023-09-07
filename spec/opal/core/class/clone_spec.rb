require 'spec_helper'

describe "Class#clone" do
  it "should copy an instance method including super call" do
    parent = Class.new do
      def hello
        "hello"
      end
    end
    child = Class.new(parent) do
      def hello
        super + " world"
      end
    end

    child.clone.new.hello.should == "hello world"
  end

  it "retains an included module in the ancestor chain" do
    klass = Class.new
    mod = Module.new do
      def hello
        "hello"
      end
    end

    klass.include(mod)
    klass.clone.new.hello.should == "hello"
  end

  it "copies a method with a block argument defined by define_method" do
    klass = Class.new
    klass.define_method(:add_one) { |&block| block.call + 1 }
    klass.clone.new.add_one { 1 }.should == 2
  end
end
