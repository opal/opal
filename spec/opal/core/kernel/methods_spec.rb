module MethodsSpecs
  class Issue < Object
    def unique_method_name
    end
  end

  # Trigger stub generation
  Issue.new.unique_method_name
end

describe "Kernel#methods" do
  it "lists methods available on an object" do
    Object.new.methods.include?("puts").should == true
  end

  it "lists only singleton methods if false is passed" do
    o = Object.new
    def o.foo; 123; end
    o.methods(false).should == ["foo"]
  end

  it "ignores stub methods" do
    Object.methods.include?(:unique_method_name).should be_false
  end
end
