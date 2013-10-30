require File.expand_path('../../../fixtures/constants', __FILE__)

describe "Module#remove_const" do
  it "removes the constant specified by a String or Symbol from the receiver's constant table" do
    ConstantSpecs::ModuleM::CS_CONST252 = :const252
    ConstantSpecs::ModuleM::CS_CONST252.should == :const252

    ConstantSpecs::ModuleM.send :remove_const, :CS_CONST252
    lambda { ConstantSpecs::ModuleM::CS_CONST252 }.should raise_error(NameError)

    ConstantSpecs::ModuleM::CS_CONST253 = :const253
    ConstantSpecs::ModuleM::CS_CONST253.should == :const253

    ConstantSpecs::ModuleM.send :remove_const, "CS_CONST253"
    lambda { ConstantSpecs::ModuleM::CS_CONST253 }.should raise_error(NameError)
  end

  it "returns the value of the removed constant" do
    ConstantSpecs::ModuleM::CS_CONST254 = :const254
    ConstantSpecs::ModuleM.send(:remove_const, :CS_CONST254).should == :const254
  end
end
