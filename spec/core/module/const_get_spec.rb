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
end

describe "Module#const_get" do
  it "accepts a String or Symbol name" do
    Object.const_get(:CS_CONST1).should == :const1
    Object.const_get("CS_CONST1").should == :const1
  end

  it "raises a NameError if no constant is defined in the search path" do
    lambda { Object.const_get :CS_CONSTX_BAD }.should raise_error(NameError)
  end

  it "searches parent scopes of classes and modules" do
    ConstGetSpecs::Bar::Baz.const_get(:BAZ).should == 300
    ConstGetSpecs::Bar::Baz.const_get(:BAR).should == 200
    ConstGetSpecs::Bar::Baz.const_get(:FOO).should == 100
    ConstGetSpecs::Bar::Baz.const_get(:Bar).should == ConstGetSpecs::Bar
  end
end
