module ConstantsSpecsModule
  MOD_CONST1 = "1"
  MOD_CONST2 = "2"
  MOD_CONST3 = "3"

  module Foo
    FOO = "foo"
  end
end

class ConstantsSpecsClass
  CLASS_CONST1 = "1"
  CLASS_CONST2 = "2"
  CLASS_CONST3 = "3"
end

class SubConstantsSpecsClass < ConstantsSpecsClass
  CLASS_CONST4 = "4"
end

describe "Module#constants" do
  it "should return constants in global scope when called from Module or Class" do
    result = Module.constants
    expect(result).to include("Module", "Object", "TrueClass", "FalseClass", "RUBY_ENGINE")
    result2 = Class.constants
    expect(result).to eq(result2)
  end

  it "should only return constants and child modules defined directly on module" do
    result = ConstantsSpecsModule.constants
    expect(result.size).to eq(4)
    expect(result).to include("MOD_CONST1", "MOD_CONST2", "MOD_CONST3", "Foo")
    result = ConstantsSpecsModule::Foo.constants
    expect(result.size).to eq(1)
    expect(result).to include("FOO")
  end

  it "should only return constants defined directly on class" do
    result = ConstantsSpecsClass.constants
    expect(result.size).to eq(3)
    expect(result).to include("CLASS_CONST1", "CLASS_CONST2", "CLASS_CONST3")
  end

  it "should include constants inherited from superclass" do
    result = SubConstantsSpecsClass.constants
    expect(result.size).to eq(4)
    expect(result).to include("CLASS_CONST4", "CLASS_CONST1", "CLASS_CONST2", "CLASS_CONST3")
  end
end
