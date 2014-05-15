require File.expand_path('../fixtures/classes', __FILE__)

describe "Module#public_method_defined?" do
  it "returns true if the named public method is defined by module or its ancestors" do
    expect(ModuleSpecs::CountsMixin.public_method_defined?("public_3")).to eq(true)

    expect(ModuleSpecs::CountsParent.public_method_defined?("public_3")).to eq(true)
    expect(ModuleSpecs::CountsParent.public_method_defined?("public_2")).to eq(true)

    expect(ModuleSpecs::CountsChild.public_method_defined?("public_3")).to eq(true)
    expect(ModuleSpecs::CountsChild.public_method_defined?("public_2")).to eq(true)
    expect(ModuleSpecs::CountsChild.public_method_defined?("public_1")).to eq(true)
  end

  it "returns false if the named method is not defined by the module or its ancestors" do
    expect(ModuleSpecs::CountsMixin.public_method_defined?(:public_10)).to eq(false)
  end
end
