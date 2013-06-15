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
    result.should include("Module", "Object", "TrueClass", "FalseClass", "RUBY_ENGINE")
    result2 = Class.constants
    result.should == result2
  end

  it "should only return constants and child modules defined directly on module" do
    result = ConstantsSpecsModule.constants
    result.size.should == 4
    result.should include("MOD_CONST1", "MOD_CONST2", "MOD_CONST3", "Foo")
    result = ConstantsSpecsModule::Foo.constants
    result.size.should == 1
    result.should include("FOO")
  end
  
  it "should only return constants defined directly on class" do
    result = ConstantsSpecsClass.constants
    result.size.should == 3
    result.should include("CLASS_CONST1", "CLASS_CONST2", "CLASS_CONST3")
  end

  it "should include constants inherited from superclass" do
    result = SubConstantsSpecsClass.constants
    result.size.should == 4
    result.should include("ClASS_CONST4", "CLASS_CONST1", "CLASS_CONST2", "CLASS_CONST3")
  end
end
