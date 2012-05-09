describe "A singleton class" do
  it "is TrueClass for true" do
    true.singleton_class.should == TrueClass
  end

  it "is FalseClass for false" do
    false.singleton_class.should == FalseClass
  end

  it "is NilClass for nil" do
    nil.singleton_class.should == NilClass
  end

  it "raises a TypeError for Fixnum's" do
    lambda { 1.singleton_class }.should raise_error(TypeError)
  end

  it "raises a TypeError for synbols" do
    lambda { :symbol.singleton_class }.should raise_error(TypeError)
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