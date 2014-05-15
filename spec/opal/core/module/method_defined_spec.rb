require File.expand_path('../fixtures/classes', __FILE__)

describe "Module#method_defined?" do
  it "returns true if a public or private method with the given name is defined in self, self's ancestors or one of self's included modules" do
    # Defined in Child
    expect(ModuleSpecs::Child.method_defined?(:public_child)).to eq(true)
    expect(ModuleSpecs::Child.method_defined?("private_child")).to eq(false)
    expect(ModuleSpecs::Child.method_defined?(:accessor_method)).to eq(true)

    # Defined in Parent
    # ModuleSpecs::Child.method_defined?("public_parent").should == true
    # ModuleSpecs::Child.method_defined?(:private_parent).should == false

    # Defined in Module
    # ModuleSpecs::Child.method_defined?(:public_module).should == true
    # ModuleSpecs::Child.method_defined?(:protected_module).should == true
    # ModuleSpecs::Child.method_defined?(:private_module).should == false

    # Defined in SuperModule
    # ModuleSpecs::Child.method_defined?(:public_super_module).should == true
    # ModuleSpecs::Child.method_defined?(:protected_super_module).should == true
    # ModuleSpecs::Child.method_defined?(:private_super_module).should == false
  end

  # unlike alias_method, module_function, public, and friends,
  it "does not search Object or Kernel when called on a module" do
    m = Module.new

    expect(m.method_defined?(:module_specs_public_method_on_kernel)).to be_false
  end

  it "raises a TypeError when the given object is not a string/symbol/fixnum" do
    c = Class.new
    o = double('123')

    expect { c.method_defined?(o) }.to raise_error(TypeError)

    expect(o).to receive(:to_str).and_return(123)
    expect { c.method_defined?(o) }.to raise_error(TypeError)
  end

  it "converts the given name to a string using to_str" do
    c = Class.new { def test(); end }
    expect(o = double('test')).to receive(:to_str).and_return("test")

    expect(c.method_defined?(o)).to eq(true)
  end
end
