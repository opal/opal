module KernelSpecs
  class Foo
    def bar
      'done'
    end

    def self.baz
      'class done'
    end
  end
end

describe "Kernel#method" do
  it "returns a method object for a valid method" do
    m = KernelSpecs::Foo.new.method(:bar)
    m.should be_kind_of(Method)
    m.call.should == 'done'
  end

  it "returns a method object for a valid singleton method" do
    m = KernelSpecs::Foo.method(:baz)
    m.should be_kind_of Method
    m.call.should == 'class done'
  end

  it "raises a NameError for an invalid method name" do
    lambda {
      KernelSpecs::Foo.new.method(:invalid_and_silly_method_name)
    }.should raise_error(NameError)
  end
end