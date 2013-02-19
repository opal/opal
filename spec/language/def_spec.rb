class DefSpecSingleton
  class << self
    def a_class_method;self;end
  end
end

describe "A method definition inside a metaclass scope" do
  it "can create a class method" do
    DefSpecSingleton.a_class_method.should == DefSpecSingleton
    lambda { Object.a_class_method }.should raise_error(NoMethodError)
  end

  it "can create a singleton method" do
    obj = Object.new
    class << obj
      def a_singleton_method;self;end
    end

    obj.a_singleton_method.should == obj
    lambda { Object.new.a_singleton_method }.should raise_error(NoMethodError)
  end
end

describe "A method definition inside an instance_eval" do
  it "creates a singleton method" do
    obj = Object.new
    obj.instance_eval do
      def an_instance_eval_method;self;end
    end
    obj.an_instance_eval_method.should == obj

    other = Object.new
    lambda { other.an_instance_eval_method }.should raise_error(NoMethodError)
  end

  it "creates a singleton method when evaluated inside a metaclass" do
    obj = Object.new
    obj.instance_eval do
      class << self
        def a_metaclass_eval_method;self;end
      end
    end
    obj.a_metaclass_eval_method.should == obj

    other = Object.new
    lambda { other.a_metaclass_eval_method }.should raise_error(NoMethodError)
  end
end
