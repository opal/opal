module ModuleAncestorsSpec
  class A; end
  class B < A; end
end

describe "Module#ancestors" do
  it "returns a list of modules in self (including self)" do
    expect(ModuleAncestorsSpec::B.ancestors.include?(ModuleAncestorsSpec::B)).to eq(true)
    expect(ModuleAncestorsSpec::B.ancestors.include?(ModuleAncestorsSpec::A)).to eq(true)
  end
end