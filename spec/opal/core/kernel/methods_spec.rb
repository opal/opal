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

describe "Kernel#__not_implemented__" do
  it "aliasing a method to __not_implemented__ returns false with respond_to?" do
    inst = Class.new { alias test __not_implemented__ }.new
    inst.respond_to?(:test).should == false
  end

  it "overwriting a method aliased to __not_implemented__ returns true with respond_to?" do
    inst = Class.new { alias test __not_implemented__ }.new
    inst.class.define_method(:test) { raise }
    inst.respond_to?(:test).should == true
  end
end
