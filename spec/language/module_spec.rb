require File.expand_path('../../spec_helper', __FILE__)

module LangModuleSpec
  module Sub1; end
end

# module LangModuleSpec::Sub2; end

describe "module" do
  it "has the right name" do
    LangModuleSpec::Sub1.name.should == "LangModuleSpec::Sub1"
    LangModuleSpec::Sub2.name.should == "LangModuleSpec::Sub2"
  end

  it "gets a name when assigned to a new constant" do
    LangModuleSpec::Anon = Module.new
    LangModuleSpec::Anon.name.should == "LangModuleSpec::Anon"
  end

  it "raises a TypeError if the contant is a class" do
    class LangModuleSpec::C1; end

    lambda {
      module LangModuleSpec::C1; end
    }.should raise_error(TypeError)
  end
end
