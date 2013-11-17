module KernelSpecs
  class Foo
    def bar
      'done'
    end

    alias :aka :bar

    def baz(*args) args end

    def foo(first, *rest) [first, *rest] end

    def buz(first = true) first end

    def self.bar
      'done'
    end
  end
end

describe "Kernel#send" do
  it "invokes the named public method" do
    KernelSpecs::Foo.new.send(:bar).should == 'done'
  end

  it "invokes the named alias of a public method" do
    KernelSpecs::Foo.new.send(:aka).should == 'done'
  end
end

describe "Kernel#send" do
  it "invokes the named method" do
    KernelSpecs::Foo.new.send(:bar).should == 'done'
  end

  it "invokes a class method if called on a class" do
    KernelSpecs::Foo.send(:bar).should == 'done'
  end

  it "succeeds if passed an arbitrary number of arguments as a splat parameter" do
    KernelSpecs::Foo.new.send(:baz).should == []
    KernelSpecs::Foo.new.send(:baz, :quux).should == [:quux]
    KernelSpecs::Foo.new.send(:baz, :quux, :foo).should == [:quux, :foo]
  end

  it "succeeds when passing 1 or more arguments as a required and a splat parameter" do
    KernelSpecs::Foo.new.send(:foo, :quux).should == [:quux]
    KernelSpecs::Foo.new.send(:foo, :quux, :bar).should == [:quux, :bar]
    KernelSpecs::Foo.new.send(:foo, :quux, :bar, :baz).should == [:quux, :bar, :baz]
  end

  it "succeeds when passing 0 arguments to a method with one parameter with a default" do
    KernelSpecs::Foo.new.send(:buz).should == true
    KernelSpecs::Foo.new.send(:buz, :arg).should == :arg
  end
end