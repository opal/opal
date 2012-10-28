module ClassExtendSpecs
  module M1
    def foo
      :class_foo
    end

    def bar
      :class_bar
    end
  end

  class C1
    extend M1
  end

  class C2 < C1
  end

  class C3 < C1
  end

  class C4 < C3
  end
end

describe "Class#extend" do
  it "class should get module methods added as class methods" do
    ClassExtendSpecs::C1.foo.should == :class_foo
    ClassExtendSpecs::C1.bar.should == :class_bar
  end

  it "class should add included methods to its .methods array" do
    ClassExtendSpecs::C1.methods.include?(:foo).should be_true
    ClassExtendSpecs::C1.methods.include?(:bar).should be_true
  end

  it "subclasses should have methods defined from superclass" do
    ClassExtendSpecs::C2.foo.should == :class_foo
    ClassExtendSpecs::C2.bar.should == :class_bar

    ClassExtendSpecs::C3.foo.should == :class_foo
    ClassExtendSpecs::C3.bar.should == :class_bar

    ClassExtendSpecs::C4.foo.should == :class_foo
    ClassExtendSpecs::C4.bar.should == :class_bar
  end
end