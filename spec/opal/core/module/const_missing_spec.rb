require File.expand_path('../../fixtures/constants', __FILE__)

describe "Module#const_missing" do
  it "is called when an undefined constant is referenced via literal form" do
    expect(ConstantSpecs::ClassA::CS_CONSTX).to eq(:CS_CONSTX)
  end

  it "is called when an undefined constant is referenced via #const_get" do
    expect(ConstantSpecs::ClassA.const_get(:CS_CONSTX)).to eq(:CS_CONSTX)
  end

  it "raises NameError and includes the name of the value that wasn't found" do
    expect {
      ConstantSpecs.const_missing("HelloMissing")
    }.to raise_error(NameError, /ConstantSpecs::HelloMissing/)
  end
end
