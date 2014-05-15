require File.expand_path('../../fixtures/constants', __FILE__)

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
    expect(Object.const_get("CS_NIL")).to be_nil
    expect(Object.const_get("CS_ZERO")).to eq(0)
    expect(Object.const_get("CS_BLANK")).to eq("")
    expect(Object.const_get("CS_FALSE")).to eq(false)
  end

  it "accepts a String or Symbol name" do
    expect(Object.const_get(:CS_CONST1)).to eq(:const1)
    expect(Object.const_get("CS_CONST1")).to eq(:const1)
  end

  it "raises a NameError if no constant is defined in the search path" do
    expect { Object.const_get :CS_CONSTX_BAD }.to raise_error(NameError)
  end

  it "raises a NameError if the name does not start with a capital letter" do
    expect { ConstantSpecs.const_get "name" }.to raise_error(NameError)
  end

  it "raises a NameError if the name starts with a non-alphabetic character" do
    expect { ConstantSpecs.const_get "__CONSTX__" }.to raise_error(NameError)
    expect { ConstantSpecs.const_get "@Name" }.to raise_error(NameError)
    expect { ConstantSpecs.const_get "!Name" }.to raise_error(NameError)
    expect { ConstantSpecs.const_get "::Name" }.to raise_error(NameError)
  end

  it "raises a NameError if the name contains non-word characters" do
    # underscore (i.e., _) is a valid word character
    expect(ConstantSpecs.const_get("CS_CONST1")).to eq(:const1)
    expect { ConstantSpecs.const_get "Name=" }.to raise_error(NameError)
    expect { ConstantSpecs.const_get "Name?" }.to raise_error(NameError)
  end

  it "searches parent scopes of classes and modules" do
    expect(Module.const_get(:ConstGetSpecs)).to eq(ConstGetSpecs)
    expect(ConstGetSpecs.const_get(:ConstGetSpecs)).to eq(ConstGetSpecs)
    expect(ConstGetSpecs::Bar::Baz.const_get(:BAZ)).to eq(300)
    expect(ConstGetSpecs::Bar::Baz.const_get(:CS_CONST1)).to eq(:const1)
    expect { ConstGetSpecs::Bar::Baz.const_get(:BAR) }.to raise_error(NameError)
    expect { ConstGetSpecs::Bar::Baz.const_get(:FOO) }.to raise_error(NameError)
    expect { ConstGetSpecs::Bar::Baz.const_get(:Bar) }.to raise_error(NameError)
    expect(ConstGetSpecs::Bar::Baz.const_get(:ConstGetSpecs)).to eq(ConstGetSpecs)
    expect(ConstGetSpecs::Dog.const_get(:LEGS)).to eq(4)
    expect { ConstGetSpecs::Dog.const_get(:Dog) }.to raise_error(NameError)
    expect(ConstGetSpecs::Bloudhound.const_get(:LEGS)).to eq(4)
  end

  it "should not search parent scopes of classes and modules if inherit is false" do
    expect { Module.const_get(:ConstGetSpecs, false) }.to raise_error(NameError)
    expect { ConstGetSpecs.const_get(:ConstGetSpecs, false) }.to raise_error(NameError)
    expect(ConstGetSpecs::Dog.const_get(:LEGS, false)).to eq(4)
    expect { ConstGetSpecs::Dog.const_get(:Dog, false) }.to raise_error(NameError)
    expect { ConstGetSpecs::Bloudhound.const_get(:LEGS, false) }.to raise_error(NameError)
  end

  it "should search parent scopes of classes and modules for Object regardless of inherit value" do
    expect(Object.const_get(:ConstGetSpecs)).to eq(ConstGetSpecs)
    expect(Object.const_get(:ConstGetSpecs, false)).to eq(ConstGetSpecs)
  end
end
