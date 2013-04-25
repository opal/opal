require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../fixtures/classes', __FILE__)

describe "Class.new with a block given" do
  it "uses the given block as the class' body" do
    klass = Class.new do
      def self.message
        "text"
      end

      def hello
        "hello again"
      end
    end

    klass.message.should == "text"
    klass.new.hello.should == "hello again"
  end

  it "creates a subclass of the given superclass" do
    sc = Class.new do
      def self.body
        @body
      end
      @body = self
      def message; "text"; end
    end
    klass = Class.new(sc) do
      def self.body
        @body
      end
      @body = self
      def message2; "hello"; end
    end

    klass.body.should == klass
    sc.body.should == sc
    klass.superclass.should == sc
    klass.new.message.should == "text"
    klass.new.message2.should == "hello"
  end

  it "runs the inherited hook after yielding the block" do
    ScratchPad.record []
    klass = Class.new(CoreClassSpecs::Inherited::D) do
      ScratchPad << self
    end

    ScratchPad.recorded.should == [CoreClassSpecs::Inherited::D, klass]
  end
end

describe "Class.new" do
  it "creates a new anonymous class" do
    klass = Class.new
    klass.is_a?(Class).should == true

    klass_instance = klass.new
    klass_instance.is_a?(klass).should == true
  end

  it "creates a class without a name" do
    Class.new.name.should be_nil
  end

  it "sets the new class' superclass to the given class" do
    top = Class.new
    Class.new(top).superclass.should == top
  end

  it "sets the new class' superclass to Object when no class given" do
    Class.new.superclass.should == Object
  end
end

describe "Class#new" do
  it "returns a new instance of self" do
    klass = Class.new
    klass.new.is_a?(klass).should == true
  end

  it "invokes #initialize on the new instance with the given args" do
    klass = Class.new do
      def initialize(*args)
        @initialized = true
        @args = args
      end

      def args
        @args
      end

      def initialized?
        @initialized || false
      end
    end

    klass.new.initialized?.should == true
    klass.new(1, 2, 3).args.should == [1, 2, 3]
  end

  it "passes the block to #initialize" do
    lambda {
      klass = Class.new do
        def initialize(&block)
          raise "no block given" unless block_given?
        end
      end

      klass.new { 42 }
    }.should_not raise_error(Exception)
  end
end
