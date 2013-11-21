module ModuleAncestorsSpec
  class A; end
  class B < A; end
end

describe "Module#ancestors" do
  it "returns a list of modules in self (including self)" do
    ModuleAncestorsSpec::B.ancestors.include?(ModuleAncestorsSpec::B).should == true
    ModuleAncestorsSpec::B.ancestors.include?(ModuleAncestorsSpec::A).should == true
  end
end