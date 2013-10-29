require File.expand_path('../../../fixtures/constants', __FILE__)

describe "Module#const_missing" do
  it "is called when an undefined constant is referenced via literal form" do
    ConstantSpecs::ClassA::CS_CONSTX.should == :CS_CONSTX
  end

  it "is called when an undefined constant is referenced via #const_get" do
    ConstantSpecs::ClassA.const_get(:CS_CONSTX).should == :CS_CONSTX
  end

  it "raises NameError and includes the name of the value that wasn't found" do
    lambda {
      ConstantSpecs.const_missing("HelloMissing")
    }.should raise_error(NameError, /ConstantSpecs::HelloMissing/)
  end
end
