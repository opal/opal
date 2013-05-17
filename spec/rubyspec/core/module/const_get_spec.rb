require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../../../fixtures/constants', __FILE__)

CS_CONST1 = :const1

module ConstGetSpecs
  FOO = 100
  
  module Bar
    BAR = 200

    module Baz
      BAZ = 300
    end
  end

  class Dog
    LEGS = 4
  end

  class Bloudhound < Dog
  end
end

describe "Module#const_get" do
  it "should get constants with values that evaluate to false in a JavaScript conditional" do
    Object.const_get("CS_NIL").should be_nil
    Object.const_get("CS_ZERO").should == 0
    Object.const_get("CS_BLANK").should == ""
    Object.const_get("CS_FALSE").should == false
  end

  it "accepts a String or Symbol name" do
    Object.const_get(:CS_CONST1).should == :const1
    Object.const_get("CS_CONST1").should == :const1
  end

  it "raises a NameError if no constant is defined in the search path" do
    lambda { Object.const_get :CS_CONSTX_BAD }.should raise_error(NameError)
  end

  it "raises a NameError if the name does not start with a capital letter" do
    lambda { ConstantSpecs.const_get "name" }.should raise_error(NameError)
  end

  it "raises a NameError if the name starts with a non-alphabetic character" do
    lambda { ConstantSpecs.const_get "__CONSTX__" }.should raise_error(NameError)
    lambda { ConstantSpecs.const_get "@Name" }.should raise_error(NameError)
    lambda { ConstantSpecs.const_get "!Name" }.should raise_error(NameError)
    lambda { ConstantSpecs.const_get "::Name" }.should raise_error(NameError)
  end

  it "raises a NameError if the name contains non-word characters" do
    # underscore (i.e., _) is a valid word character
    ConstantSpecs.const_get("CS_CONST1").should == :const1
    lambda { ConstantSpecs.const_get "Name=" }.should raise_error(NameError)
    lambda { ConstantSpecs.const_get "Name?" }.should raise_error(NameError)
  end

  it "searches parent scopes of classes and modules" do
    Module.const_get(:ConstGetSpecs).should == ConstGetSpecs
    ConstGetSpecs.const_get(:ConstGetSpecs).should == ConstGetSpecs
    ConstGetSpecs::Bar::Baz.const_get(:BAZ).should == 300
    ConstGetSpecs::Bar::Baz.const_get(:CS_CONST1).should == :const1
    lambda { ConstGetSpecs::Bar::Baz.const_get(:BAR) }.should raise_error(NameError)
    lambda { ConstGetSpecs::Bar::Baz.const_get(:FOO) }.should raise_error(NameError)
    lambda { ConstGetSpecs::Bar::Baz.const_get(:Bar) }.should raise_error(NameError)
    ConstGetSpecs::Bar::Baz.const_get(:ConstGetSpecs).should == ConstGetSpecs
    ConstGetSpecs::Dog.const_get(:LEGS).should == 4
    lambda { ConstGetSpecs::Dog.const_get(:Dog) }.should raise_error(NameError)
    ConstGetSpecs::Bloudhound.const_get(:LEGS).should == 4
  end

  it "should not search parent scopes of classes and modules if inherit is false" do
    lambda { Module.const_get(:ConstGetSpecs, false) }.should raise_error(NameError)
    lambda { ConstGetSpecs.const_get(:ConstGetSpecs, false) }.should raise_error(NameError)
    ConstGetSpecs::Dog.const_get(:LEGS, false).should == 4
    lambda { ConstGetSpecs::Dog.const_get(:Dog, false) }.should raise_error(NameError)
    lambda { ConstGetSpecs::Bloudhound.const_get(:LEGS, false) }.should raise_error(NameError)
  end

  it "should search parent scopes of classes and modules for Object regardless of inherit value" do
    Object.const_get(:ConstGetSpecs).should == ConstGetSpecs
    Object.const_get(:ConstGetSpecs, false).should == ConstGetSpecs
  end
end
