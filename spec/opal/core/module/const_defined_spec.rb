require File.expand_path('../../fixtures/constants', __FILE__)

CD_CONST1 = :const1

module ConstDefinedSpecs
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

describe "Module#const_defined?" do
  it "should consider constants with values that evaluate to false in a JavaScript conditional as defined" do
    Object.const_defined?("CS_NIL").should be_true
    Object.const_defined?("CS_ZERO").should be_true
    Object.const_defined?("CS_BLANK").should be_true
    Object.const_defined?("CS_FALSE").should be_true
  end

  it "accepts a String or Symbol name" do
    Object.const_defined?(:CD_CONST1).should be_true
    Object.const_defined?("CD_CONST1").should be_true
  end

  it "should return false if no constant is defined in the search path" do
    Object.const_defined?(:CS_CONSTX_BAD).should be_false
  end

  it "raises a NameError if the name does not start with a capital letter" do
    lambda { ConstantSpecs.const_defined? "name" }.should raise_error(NameError)
  end

  it "raises a NameError if the name starts with a non-alphabetic character" do
    lambda { ConstantSpecs.const_defined? "__CONSTX__" }.should raise_error(NameError)
    lambda { ConstantSpecs.const_defined? "@Name" }.should raise_error(NameError)
    lambda { ConstantSpecs.const_defined? "!Name" }.should raise_error(NameError)
    lambda { ConstantSpecs.const_defined? "::Name" }.should raise_error(NameError)
  end

  it "raises a NameError if the name contains non-word characters" do
    # underscore (i.e., _) is a valid word character
    ConstantSpecs.const_defined?("CD_CONST1").should be_true
    lambda { ConstantSpecs.const_defined? "Name=" }.should raise_error(NameError)
    lambda { ConstantSpecs.const_defined? "Name?" }.should raise_error(NameError)
  end

  it "searches parent scopes of classes and modules" do
    Module.const_defined?(:ConstDefinedSpecs).should be_true
    ConstDefinedSpecs.const_defined?(:ConstDefinedSpecs).should be_true
    ConstDefinedSpecs::Bar::Baz.const_defined?(:BAZ).should be_true
    ConstDefinedSpecs::Bar::Baz.const_defined?(:CD_CONST1).should be_true
    ConstDefinedSpecs::Bar::Baz.const_defined?(:BAR).should be_false
    ConstDefinedSpecs::Bar::Baz.const_defined?(:FOO).should be_false
    ConstDefinedSpecs::Bar::Baz.const_defined?(:Bar).should be_false
    ConstDefinedSpecs::Bar::Baz.const_defined?(:ConstDefinedSpecs).should be_true
    ConstDefinedSpecs::Dog.const_defined?(:LEGS).should be_true
    ConstDefinedSpecs::Dog.const_defined?(:Dog).should be_false
    ConstDefinedSpecs::Bloudhound.const_defined?(:LEGS).should be_true
  end

  it "should not search parent scopes of classes and modules if inherit is false" do
    Module.const_defined?(:ConstDefinedSpecs, false).should be_false
    ConstDefinedSpecs.const_defined?(:ConstDefinedSpecs, false).should be_false
    ConstDefinedSpecs::Dog.const_defined?(:LEGS, false).should be_true
    ConstDefinedSpecs::Dog.const_defined?(:Dog, false).should be_false
    ConstDefinedSpecs::Bloudhound.const_defined?(:LEGS, false).should be_false
  end

  it "should search parent scopes of classes and modules for Object regardless of inherit value" do
    Object.const_defined?(:ConstDefinedSpecs).should be_true
    Object.const_defined?(:ConstDefinedSpecs, false).should be_true
  end
end
