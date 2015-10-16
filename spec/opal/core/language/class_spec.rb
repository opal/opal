class AssignClassNewConst
  TEST_CONST = :bar
  
  def foo
    TEST_CONST
  end
  
  def self.assign_klass
    k = Class.new(self) do
      def foobar
        # ensure we can still use constants from AssignClassNewConst even though we use AssignClassConstBase
        TEST_CONST
      end
    end
    AssignClassConstBase.assign_const(k)
  end
end

module AssignClassConstBase
  def self.assign_const(group)
    self.const_set("MyStuff", group)    
  end
end

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
  
  it "respects a different base scope" do
    AssignClassNewConst.assign_klass
    AssignClassConstBase::MyStuff.to_s.should == "AssignClassConstBase::MyStuff"
    AssignClassConstBase::MyStuff.name.should == "AssignClassConstBase::MyStuff"
    obj = AssignClassConstBase::MyStuff.new
    obj.foo.should == :bar
    obj.foobar.should == :bar
  end
end
