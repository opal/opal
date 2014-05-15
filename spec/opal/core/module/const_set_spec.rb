require File.expand_path('../../fixtures/constants', __FILE__)

module ConstantSpecs
end

describe "Module#const_set" do
  it "sets the constant specified by a String or Symbol to the given value" do
    ConstantSpecs.const_set :CS_CONST401, :const401
    expect(ConstantSpecs::CS_CONST401).to eq(:const401)

    ConstantSpecs.const_set "CS_CONST402", :const402
    expect(ConstantSpecs.const_get(:CS_CONST402)).to eq(:const402)
  end

  it "returns the value set" do
    expect(ConstantSpecs.const_set(:CS_CONST403, :const403)).to eq(:const403)
  end

  # PENDING: needs proper parser implementation
  #
  # it "sets the name of an anonymous module" do
  #   m = Module.new
  #   ConstantSpecs.const_set(:CS_CONST1000, m)
  #   m.name.should == "ConstantSpecs::CS_CONST1000"
  # end

  it "raises a NameError if the name does not start with a capital letter" do
    expect { ConstantSpecs.const_set "name", 1 }.to raise_error(NameError)
  end

  it "raises a NameError if the name starts with a non-alphabetic character" do
    expect { ConstantSpecs.const_set "__CONSTX__", 1 }.to raise_error(NameError)
    expect { ConstantSpecs.const_set "@Name", 1 }.to raise_error(NameError)
    expect { ConstantSpecs.const_set "!Name", 1 }.to raise_error(NameError)
    expect { ConstantSpecs.const_set "::Name", 1 }.to raise_error(NameError)
  end

  it "raises a NameError if the name contains non-word characters" do
    # underscore (i.e., _) is a valid word character
    expect(ConstantSpecs.const_set("CS_CONST404", :const404)).to eq(:const404)
    expect { ConstantSpecs.const_set "Name=", 1 }.to raise_error(NameError)
    expect { ConstantSpecs.const_set "Name?", 1 }.to raise_error(NameError)
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
