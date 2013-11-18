module KernelExtendSpecs
  module Mod
    def foo; 3.142; end
  end

  class A
    extend Mod
  end
end

describe "Kernel#extend" do
  it "extends the class/module with the module" do
    KernelExtendSpecs::A.foo.should == 3.142
  end

  it "extends the object with the module" do
    obj = Object.new
    obj.extend KernelExtendSpecs::Mod
    obj.foo.should == 3.142
  end
end