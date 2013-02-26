require "spec_helper"

module ClassProcMethodsSpec
  class A; end

  class B
    def self.[](a); :foo; end
  end

  class C < B; end
end

describe "Class: proc methods" do
  it "classes should not inherit proc methods" do
    ClassProcMethodsSpec::A.respond_to?(:[]).should be_false
    ClassProcMethodsSpec::A.respond_to?(:call).should be_false
  end

  it "subclasses inherit proc methods if defined on suprt class" do
    ClassProcMethodsSpec::B[nil].should eq(:foo)
    ClassProcMethodsSpec::C[nil].should eq(:foo)
  end
end
