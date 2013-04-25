require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../../../fixtures/constants', __FILE__)


module ConstantSpecs
end

describe "Module#const_set" do
  it "sets the constant specified by a String or Symbol to the given value" do
    ConstantSpecs.const_set :CS_CONST401, :const401
    ConstantSpecs::CS_CONST401.should == :const401

    ConstantSpecs.const_set "CS_CONST402", :const402
    ConstantSpecs.const_get(:CS_CONST402).should == :const402
  end

  it "returns the value set" do
    ConstantSpecs.const_set(:CS_CONST403, :const403).should == :const403
  end

  # PENDING: needs proper parser implementation
  #
  # it "sets the name of an anonymous module" do
  #   m = Module.new
  #   ConstantSpecs.const_set(:CS_CONST1000, m)
  #   m.name.should == "ConstantSpecs::CS_CONST1000"
  # end

  it "raises a NameError if the name does not start with a capital letter" do
    lambda { ConstantSpecs.const_set "name", 1 }.should raise_error(NameError)
  end

  it "raises a NameError if the name starts with a non-alphabetic character" do
    lambda { ConstantSpecs.const_set "__CONSTX__", 1 }.should raise_error(NameError)
    lambda { ConstantSpecs.const_set "@Name", 1 }.should raise_error(NameError)
    lambda { ConstantSpecs.const_set "!Name", 1 }.should raise_error(NameError)
    lambda { ConstantSpecs.const_set "::Name", 1 }.should raise_error(NameError)
  end

  it "raises a NameError if the name contains non-alphabetic characters except '_'" do
    ConstantSpecs.const_set("CS_CONST404", :const404).should == :const404
    lambda { ConstantSpecs.const_set "Name=", 1 }.should raise_error(NameError)
    lambda { ConstantSpecs.const_set "Name?", 1 }.should raise_error(NameError)
  end

  # PENDING: should_receive isn't available on opal-spec
  #
  # it "calls #to_str to convert the given name to a String" do
  #
  #   name = mock("CS_CONST405")
  #   name.should_receive(:to_str).and_return("CS_CONST405")
  #   ConstantSpecs.const_set(name, :const405).should == :const405
  #   ConstantSpecs::CS_CONST405.should == :const405
  # end

  # PENDING: should_receive isn't available on opal-spec
  #
  # it "raises a TypeError if conversion to a String by calling #to_str fails" do
  #   name = mock('123')
  #   lambda { ConstantSpecs.const_set name, 1 }.should raise_error(TypeError)
  #
  #   name.should_receive(:to_str).and_return(123)
  #   lambda { ConstantSpecs.const_set name, 1 }.should raise_error(TypeError)
  # end
end
