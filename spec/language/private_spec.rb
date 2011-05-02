require File.expand_path('../../spec_helper', __FILE__)
require File.expand_path('../fixtures/private', __FILE__)

describe "The private keyword" do
  it "marks following methods as being private" do
    a = Private::A.new
    lambda { a.bar }.should raise_error(NoMethodError)

    b = Private::B.new
    lambda { b.bar }.should raise_error(NoMethodError)
  end

  it "is overridden when a new class is opened" do
    c = Private::B::C.new
    c.baz
    Private::B.public_class_method1.should == 1
    Private::B.public_class_method2.should == 2
    lambda { Private::B.private_class_method1 }.should raise_error(NoMethodError)
  end

  it "is no longer in effect when the class is closed" do
    b = Private::B.new
    b.foo
  end

  it "changes visibility of previously called method" do
    f = Private::F.new
    f.foo
    module Private
      class F
        private :foo
      end
    end
    lambda { f.foo }.should raise_error(NoMethodError)
  end
end


