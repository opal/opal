require File.expand_path('../../spec_helper', __FILE__)
require File.expand_path('../../fixtures/class', __FILE__)

describe "A singleton class" do
  it "is NilClass for nil" do
    nil.singleton_class.should == NilClass
  end

  it "is a singleton Class instance" do
    o = mock('x')
    o.singleton_class.should be_kind_of(Class)
    o.singleton_class.should_not equal(Object)
    o.should_not be_kind_of(o.singleton_class)
  end

  it "is a Class for classes" do
    ClassSpecs::A::singleton_class.should be_kind_of(Class)
  end
end

describe "Defining instance methods on a singleton class" do
  before do
    @object = Object.new
    class << @object
      def singleton_method; 1 end
    end
  end

  it "defines public methods" do
    @object.singleton_method.should == 1
  end
end
