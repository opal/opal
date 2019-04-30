module PublicMethodsSpecs
  class Parent
    def parent_method
    end
  end

  class Child < Parent
    def child_method
    end
  end
end

describe "Kernel#public_methods" do
  it "lists methods available on an object" do
    child = PublicMethodsSpecs::Child.new
    child.public_methods.include?("parent_method").should == true
    child.public_methods.include?("child_method").should == true
  end

  it "lists only those methods in the receiver if false is passed" do
    child = PublicMethodsSpecs::Child.new
    def child.singular_method; 1123; end
    child.public_methods(false).sort.should == ["child_method", "singular_method"]
  end
end
