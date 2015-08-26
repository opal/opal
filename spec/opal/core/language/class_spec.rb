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

describe "Class descendant check using < operator" do
  klass1 = Class.new
  klass2 = Class.new(klass1)
  klass3 = Class.new
  
  it "is a descendant" do
    (klass2 < klass1).should == true    
  end
  
  it "is not a descendant" do
    (klass3 < klass1).should == false
  end
  
  it "is the same class" do
    (klass1 < klass1).should == false
  end 
end
