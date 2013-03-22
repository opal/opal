require File.expand_path('../../spec_helper', __FILE__)
require File.expand_path('../../fixtures/class_variables', __FILE__)

describe "A class variable" do
  it "can be accessed from a subclass" do
    ClassVariablesSpec::ClassB.new.cvar_a.should == :cvar_a
  end

  it "is set in the superclass" do
    a = ClassVariablesSpec::ClassA.new
    b = ClassVariablesSpec::ClassB.new
    b.cvar_a = :new_val

    a.cvar_a.should == :new_val
  end
end

describe "A class variable defined in a module" do
  it "can be accessed from classes that extend the module" do
    ClassVariablesSpec::ClassC.cvar_m.should == :value
  end

  it "is not defined in these classes" do
    ClassVariablesSpec::ClassC.cvar_defined?.should be_false
  end

  it "is only updated in the module a method defined in the module is used" do
    ClassVariablesSpec::ClassC.cvar_m = "new value"
    ClassVariablesSpec::ClassC.cvar_m.should == "new value"

    ClassVariablesSpec::ClassC.cvar_defined?.should be_false
  end

  it "is updated in the class when a Method defined in the class is used" do
    ClassVariablesSpec::ClassC.cvar_c = "new value"
    ClassVariablesSpec::ClassC.cvar_defined?.should be_true
  end

  it "can be accessed inside the class using the module methods" do
    ClassVariablesSpec::ClassC.cvar_c = "new value"

    ClassVariablesSpec::ClassC.cvar_m.should == "new value"
  end

  it "can be accessed from modules that extend the module" do
    ClassVariablesSpec::ModuleO.cvar_n.should == :value
  end

  it "is defined in the extended module" do
    ClassVariablesSpec::ModuleN.class_variable_defined?(:@@cvar_n).should be_true
  end

  it "is not defined in the extending module" do
    ClassVariablesSpec::ModuleO.class_variable_defined?(:@@cvar_n).should be_false
  end
end
