require File.expand_path('../../fixtures/constants', __FILE__)

describe "Module#remove_const" do
  it "removes the constant specified by a String or Symbol from the receiver's constant table" do
    ConstantSpecs::ModuleM::CS_CONST252 = :const252
    expect(ConstantSpecs::ModuleM::CS_CONST252).to eq(:const252)

    ConstantSpecs::ModuleM.send :remove_const, :CS_CONST252
    expect { ConstantSpecs::ModuleM::CS_CONST252 }.to raise_error(NameError)

    ConstantSpecs::ModuleM::CS_CONST253 = :const253
    expect(ConstantSpecs::ModuleM::CS_CONST253).to eq(:const253)

    ConstantSpecs::ModuleM.send :remove_const, "CS_CONST253"
    expect { ConstantSpecs::ModuleM::CS_CONST253 }.to raise_error(NameError)
  end

  it "returns the value of the removed constant" do
    ConstantSpecs::ModuleM::CS_CONST254 = :const254
    expect(ConstantSpecs::ModuleM.send(:remove_const, :CS_CONST254)).to eq(:const254)
  end
end
