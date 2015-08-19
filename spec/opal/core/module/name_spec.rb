require 'spec_helper'

module ModuleNameSpec
  module A
    class B
    end
  end
end

describe "Module#name" do
  it "should return the class name for boot types" do
    BasicObject.name.should == "BasicObject"
    Object.name.should == "Object"
    Class.name.should == "Class"
    Module.name.should == "Module"
  end

  it "should return class name for bridged classes" do
    Array.name.should == "Array"
  end

  it "should return name for modules and classes" do
    Enumerator.name.should == "Enumerator"
    Enumerable.name.should == "Enumerable"
  end

  it "should return nil for anonymous class" do
    Class.new.name.should == nil
  end

  it "should join nested classes using '::'" do
    ModuleNameSpec::A.name.should == "ModuleNameSpec::A"
    ModuleNameSpec::A::B.name.should == "ModuleNameSpec::A::B"
  end
end
