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
    expect(KernelSpecs::Foo.new.send(:bar)).to eq('done')
  end

  it "invokes the named alias of a public method" do
    expect(KernelSpecs::Foo.new.send(:aka)).to eq('done')
  end
end

describe "Kernel#send" do
  it "invokes the named method" do
    expect(KernelSpecs::Foo.new.send(:bar)).to eq('done')
  end

  it "invokes a class method if called on a class" do
    expect(KernelSpecs::Foo.send(:bar)).to eq('done')
  end

  it "succeeds if passed an arbitrary number of arguments as a splat parameter" do
    expect(KernelSpecs::Foo.new.send(:baz)).to eq([])
    expect(KernelSpecs::Foo.new.send(:baz, :quux)).to eq([:quux])
    expect(KernelSpecs::Foo.new.send(:baz, :quux, :foo)).to eq([:quux, :foo])
  end

  it "succeeds when passing 1 or more arguments as a required and a splat parameter" do
    expect(KernelSpecs::Foo.new.send(:foo, :quux)).to eq([:quux])
    expect(KernelSpecs::Foo.new.send(:foo, :quux, :bar)).to eq([:quux, :bar])
    expect(KernelSpecs::Foo.new.send(:foo, :quux, :bar, :baz)).to eq([:quux, :bar, :baz])
  end

  it "succeeds when passing 0 arguments to a method with one parameter with a default" do
    expect(KernelSpecs::Foo.new.send(:buz)).to eq(true)
    expect(KernelSpecs::Foo.new.send(:buz, :arg)).to eq(:arg)
  end
end