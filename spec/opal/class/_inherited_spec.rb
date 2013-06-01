require "spec_helper"

class Class
  def get_inherited_classes
    `#{self}._inherited || []`
  end
end

module ClassInheritedSpecs
  class None
  end

  class A
  end

  class B < A
  end

  class C < A
  end

  class D < C
  end
end

describe "Class '_inherited' variable" do
  it "contains an array of all subclasses of class" do
    ClassInheritedSpecs::None.get_inherited_classes.should == []
    ClassInheritedSpecs::A.get_inherited_classes.should == [ClassInheritedSpecs::B, ClassInheritedSpecs::C]
    ClassInheritedSpecs::C.get_inherited_classes.should == [ClassInheritedSpecs::D]
  end
end
