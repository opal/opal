require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../fixtures/classes', __FILE__)

describe "Module#public_method_defined?" do
  it "returns true if the named public method is defined by module or its ancestors" do
    ModuleSpecs::CountsMixin.public_method_defined?("public_3").should == true

    ModuleSpecs::CountsParent.public_method_defined?("public_3").should == true
    ModuleSpecs::CountsParent.public_method_defined?("public_2").should == true

    ModuleSpecs::CountsChild.public_method_defined?("public_3").should == true
    ModuleSpecs::CountsChild.public_method_defined?("public_2").should == true
    ModuleSpecs::CountsChild.public_method_defined?("public_1").should == true
  end

  it "returns false if the named method is not defined by the module or its ancestors" do
    ModuleSpecs::CountsMixin.public_method_defined?(:public_10).should == false
  end
end
