require File.expand_path('../../spec_helper', __FILE__)
require File.expand_path('../fixtures/module', __FILE__)

describe "The module keyword" do
  pending "creates a new module with a non-qualified constant name" do
    module ModuleSpecsToplevel; end
    ModuleSpecsToplevel.should be_an_instance_of(Module)
  end

  pending "creates a new module with a qualified constant name" do
    module ModuleSpecs::Nested; end
    ModuleSpecs::Nested.should be_an_instance_of(Module)
  end

  pending "creates a new module with a variable qualified constant name" do
    m = Module.new
    module m::N; end
    m::N.should be_an_instance_of(Module)
  end

  pending "reopens an existing module" do
    module ModuleSpecs; Reopened = true; end
    ModuleSpecs::Reopened.should be_true
  end

  pending "reopens a module included in Object" do
    module IncludedModuleSpecs; Reopened = true; end
    ModuleSpecs::IncludedInObject::IncludedModuleSpecs::Reopened.should be_true
  end

  pending "raises a TypeError if the constant is a Class" do
    lambda do
      module ModuleSpecs::Modules::Klass; end
    end.should raise_error(TypeError)
  end

  pending "raises a TypeError if the constant is a String" do
    lambda { module ModuleSpecs::Modules::A; end }.should raise_error(TypeError)
  end

  pending "raises a TypeError if the constant is a Fixnum" do
    lambda { module ModuleSpecs::Modules::B; end }.should raise_error(TypeError)
  end

  pending "raises a TypeError if the constant is nil" do
    lambda { module ModuleSpecs::Modules::C; end }.should raise_error(TypeError)
  end

  pending "raises a TypeError if the constant is true" do
    lambda { module ModuleSpecs::Modules::D; end }.should raise_error(TypeError)
  end

  pending "raises a TypeError if the constant is false" do
    lambda { module ModuleSpecs::Modules::D; end }.should raise_error(TypeError)
  end
end
