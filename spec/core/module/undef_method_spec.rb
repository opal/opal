require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../fixtures/classes', __FILE__)

module ModuleSpecs
  class NoInheritance
    def method_to_undef() 1 end
    def another_method_to_undef() 1 end
  end

  class Parent
    def method_to_undef() 1 end
    def another_method_to_undef() 1 end
  end

  class Child < Parent
  end

  class Ancestor
    def method_to_undef() 1 end
    def another_method_to_undef() 1 end
  end

  class Descendant < Ancestor
  end
end

describe "Module#undef_method with symbol" do
  it "removes a method defined in a class" do
    x = ModuleSpecs::NoInheritance.new

    x.method_to_undef.should == 1

    ModuleSpecs::NoInheritance.send :undef_method, :method_to_undef

    lambda { x.method_to_undef }.should raise_error(NoMethodError)
  end

  it "removes a method defined in a super class" do
    child = ModuleSpecs::Child.new
    child.method_to_undef.should == 1

    ModuleSpecs::Child.send :undef_method, :method_to_undef

    lambda { child.method_to_undef }.should raise_error(NoMethodError)
  end
end

describe "Module#undef_method with string" do
  it "removes a method defined in a class" do
    x = ModuleSpecs::NoInheritance.new

    x.another_method_to_undef.should == 1

    ModuleSpecs::NoInheritance.send :undef_method, 'another_method_to_undef'

    lambda { x.another_method_to_undef }.should raise_error(NoMethodError)
  end

  it "removes a method defined in a super class" do
    child = ModuleSpecs::Child.new
    child.another_method_to_undef.should == 1

    ModuleSpecs::Child.send :undef_method, 'another_method_to_undef'

    lambda { child.another_method_to_undef }.should raise_error(NoMethodError)
  end
end
