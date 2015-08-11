describe "Assigning Class.new to a constant" do
  klass = Class.new do
    def bar
      :bar
    end
  end
  ConstantWithAssignedClass = klass
  class ConstantWithAssignedClass
    def foo
      :foo
    end
  end

  it "sets the class' name" do
    ConstantWithAssignedClass.name.should == 'ConstantWithAssignedClass'
  end

  it "can be reopened by the constant name" do
    ConstantWithAssignedClass.new.foo.should == :foo
    ConstantWithAssignedClass.new.bar.should == :bar
  end
end
