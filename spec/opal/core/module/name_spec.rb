require 'spec_helper'

module ModuleNameSpec
  module A
    class B
    end
  end
end

describe "Module#name" do
  it "should return the class name for boot types" do
    expect(BasicObject.name).to eq("BasicObject")
    expect(Object.name).to eq("Object")
    expect(Class.name).to eq("Class")
    expect(Module.name).to eq("Module")
  end

  it "should return class name for bridged classes" do
    expect(Array.name).to eq("Array")
  end

  it "should return name for modules and classes" do
    expect(Enumerator.name).to eq("Enumerator")
    expect(Enumerable.name).to eq("Enumerable")
  end

  it "should return nil for anonymous class" do
    expect(Class.new.name).to eq(nil)
  end

  it "should join nested classes using '::'" do
    expect(ModuleNameSpec::A.name).to eq("ModuleNameSpec::A")
    expect(ModuleNameSpec::A::B.name).to eq("ModuleNameSpec::A::B")
  end

  it "uses just child name when class set inside anonymous parent" do
    a = Class.new
    b = Class.new
    a.const_set :Child, b
    expect(b.name).to eq("Child")
  end

  it "uses parent name once parent anonymous class gets name" do
    a = Class.new
    b = Class.new
    a.const_set :Child, b
    expect(b.name).to eq("Child")

    ModuleNameSpec.const_set :Parent, a
    expect(b.name).to eq("ModuleNameSpec::Parent::Child")
  end
end
