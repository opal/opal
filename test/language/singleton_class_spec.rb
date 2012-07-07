describe "A singleton class" do
  it "is NilClass for nil" do
    nil.singleton_class.should == NilClass
  end

  it "is a singleton Class instance" do
    o = mock('x')
    o.singleton_class.should be_kind_of(Class)
    o.singleton_class.should_not equal(Object)
  end

  it "is a Class for classes" do
    ClassSpecs::A::singleton_class.should be_kind_of(Class)
  end
end

module ClassSpecs
  class A; end
end