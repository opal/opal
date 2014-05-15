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
    expect(Object.new.methods.include?("puts")).to eq(true)
  end

  it "lists only singleton methods if false is passed" do
    o = Object.new
    def o.foo; 123; end
    expect(o.methods(false)).to eq(["foo"])
  end

  it "ignores stub methods" do
    expect(Object.methods.include?(:unique_method_name)).to be_false
  end
end
