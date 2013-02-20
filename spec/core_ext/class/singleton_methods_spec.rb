require "spec_helper"

module ClassSingletonSpecs
  class A
    def self.foo; :foo; end
    def self.bar; :bar; end
  end

  class B < A
    def self.bar; :baz; end
  end

  class C < B
  end

  class A
    def self.woosh; :kapow; end
  end
end

describe "Class singleton methods" do
  it "should be inherited by subclasses" do
    ClassSingletonSpecs::B.foo.should eq(:foo)
  end

  it "should be inherited by subclasses of subclasses" do
    ClassSingletonSpecs::C.foo.should eq(:foo)
  end

  it "subclasses can override inherited methods" do
    ClassSingletonSpecs::A.bar.should eq(:bar)
    ClassSingletonSpecs::B.bar.should eq(:baz)
    ClassSingletonSpecs::C.bar.should eq(:baz)
  end

  it "subclasses inherit additional methods defined on superclass after they are defined" do
    ClassSingletonSpecs::A.woosh.should eq(:kapow)
    ClassSingletonSpecs::B.woosh.should eq(:kapow)
    ClassSingletonSpecs::C.woosh.should eq(:kapow)
  end
end
