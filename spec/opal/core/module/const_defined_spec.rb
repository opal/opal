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
    expect(Object.const_defined?("CS_NIL")).to be_true
    expect(Object.const_defined?("CS_ZERO")).to be_true
    expect(Object.const_defined?("CS_BLANK")).to be_true
    expect(Object.const_defined?("CS_FALSE")).to be_true
  end

  it "accepts a String or Symbol name" do
    expect(Object.const_defined?(:CD_CONST1)).to be_true
    expect(Object.const_defined?("CD_CONST1")).to be_true
  end

  it "should return false if no constant is defined in the search path" do
    expect(Object.const_defined?(:CS_CONSTX_BAD)).to be_false
  end

  it "raises a NameError if the name does not start with a capital letter" do
    expect { ConstantSpecs.const_defined? "name" }.to raise_error(NameError)
  end

  it "raises a NameError if the name starts with a non-alphabetic character" do
    expect { ConstantSpecs.const_defined? "__CONSTX__" }.to raise_error(NameError)
    expect { ConstantSpecs.const_defined? "@Name" }.to raise_error(NameError)
    expect { ConstantSpecs.const_defined? "!Name" }.to raise_error(NameError)
    expect { ConstantSpecs.const_defined? "::Name" }.to raise_error(NameError)
  end

  it "raises a NameError if the name contains non-word characters" do
    # underscore (i.e., _) is a valid word character
    expect(ConstantSpecs.const_defined?("CD_CONST1")).to be_true
    expect { ConstantSpecs.const_defined? "Name=" }.to raise_error(NameError)
    expect { ConstantSpecs.const_defined? "Name?" }.to raise_error(NameError)
  end

  it "searches parent scopes of classes and modules" do
    expect(Module.const_defined?(:ConstDefinedSpecs)).to be_true
    expect(ConstDefinedSpecs.const_defined?(:ConstDefinedSpecs)).to be_true
    expect(ConstDefinedSpecs::Bar::Baz.const_defined?(:BAZ)).to be_true
    expect(ConstDefinedSpecs::Bar::Baz.const_defined?(:CD_CONST1)).to be_true
    expect(ConstDefinedSpecs::Bar::Baz.const_defined?(:BAR)).to be_false
    expect(ConstDefinedSpecs::Bar::Baz.const_defined?(:FOO)).to be_false
    expect(ConstDefinedSpecs::Bar::Baz.const_defined?(:Bar)).to be_false
    expect(ConstDefinedSpecs::Bar::Baz.const_defined?(:ConstDefinedSpecs)).to be_true
    expect(ConstDefinedSpecs::Dog.const_defined?(:LEGS)).to be_true
    expect(ConstDefinedSpecs::Dog.const_defined?(:Dog)).to be_false
    expect(ConstDefinedSpecs::Bloudhound.const_defined?(:LEGS)).to be_true
  end

  it "should not search parent scopes of classes and modules if inherit is false" do
    expect(Module.const_defined?(:ConstDefinedSpecs, false)).to be_false
    expect(ConstDefinedSpecs.const_defined?(:ConstDefinedSpecs, false)).to be_false
    expect(ConstDefinedSpecs::Dog.const_defined?(:LEGS, false)).to be_true
    expect(ConstDefinedSpecs::Dog.const_defined?(:Dog, false)).to be_false
    expect(ConstDefinedSpecs::Bloudhound.const_defined?(:LEGS, false)).to be_false
  end

  it "should search parent scopes of classes and modules for Object regardless of inherit value" do
    expect(Object.const_defined?(:ConstDefinedSpecs)).to be_true
    expect(Object.const_defined?(:ConstDefinedSpecs, false)).to be_true
  end
end
