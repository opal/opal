require File.expand_path('../../spec_helper', __FILE__)

# Language-level method behaviour
describe "Redefining a method" do
  it "replaces the original method" do
    def barfoo; 100; end
    barfoo.should == 100

    def barfoo; 200; end
    barfoo.should == 200
  end
end

describe "Defining an 'initialize' method" do
  pending "sets the method's visibility to private" do
    class DefInitializeSpec
      def initialize
      end
    end
    DefInitializeSpec.should have_private_instance_method(:initialize, false)
  end
end

describe "Defining an 'initialize_copy' method" do
  pending "sets the method's visibility to private" do
    class DefInitializeCopySpec
      def initialize_copy
      end
    end
    DefInitializeCopySpec.should have_private_instance_method(:initialize_copy, false)
  end
end

describe "An instance method definition with a splat" do
  it "accepts an unnamed '*' argument" do
    def foo(*); end;

    foo.should == nil
    foo(1, 2).should == nil
    foo(1, 2, 3, 4, :a, :b, 'c', 'd').should == nil
  end

  it "accepts a named * argument" do
    def foo(*a); a; end;
    foo.should == []
    foo(1, 2).should == [1, 2]
    foo([:a]).should == [[:a]]
  end

  it "accepts non-* arguments before the * argument" do
    def foo(a, b, c, d, e, *f); [a, b, c, d, e, f]; end
    foo(1, 2, 3, 4, 5, 6, 7, 8).should == [1, 2, 3, 4, 5, [6, 7, 8]]
  end

  it "allows only a single * argument" do
    lambda { eval 'def foo(a, *b, *c); end' }.should raise_error(SyntaxError)
  end

  it "requires the presence of any arguments that precede the *" do
    def foo(a, b, *c); end
    lambda { foo 1 }.should raise_error(ArgumentError)
  end
end

describe "An instance method with a default argument" do
  it "evaluates the default when no arguments are passed" do
    def foo(a = 1)
      a
    end
    foo.should == 1
    foo(2).should == 2
  end

  it "evaluates the default empty expression when no arguments are passed" do
    def foo(a = ())
      a
    end
    foo.should == nil
    foo(2).should == 2
  end

  it "assigns an empty Array to an unused splat argument" do
    def foo(a = 1, *b)
      [a,b]
    end
    foo.should == [1, []]
    foo(2).should == [2, []]
  end

  it "evaluates the default when required arguments precede it" do
    def foo(a, b = 2)
      [a,b]
    end
    lambda { foo }.should raise_error(ArgumentError)
    foo(1).should == [1, 2]
  end

  it "prefers to assign to a default argument before a splat argument" do
    def foo(a, b = 2, *c)
      [a,b,c]
    end
    lambda { foo }.should raise_error(ArgumentError)
    foo(1).should == [1,2,[]]
  end

  it "prefers to assign to a default argument when there are no required arguments" do
    def foo(a = 1, *args)
      [a,args]
    end
    foo(2,2).should == [2,[2]]
  end

  it "does not evaluate the default when passed a value and a * argument" do
    def foo(a, b = 2, *args)
      [a,b,args]
    end
    foo(2,3,3).should == [2,3,[3]]
  end
end

describe "A singleton method definition" do
  after :all do
    Object.remove_class_variable :@@a rescue nil
  end

  pending "can be declared for a local variable" do
    a = "hi"
    def a.foo
      5
    end
    a.foo.should == 5
  end

  pending "can be declared for an instance variable" do
    @a = "hi"
    def @a.foo
      6
    end
    @a.foo.should == 6
  end

  pending "can be declared for a global variable" do
    $__a__ = "hi"
    def $__a__.foo
     7
    end
    $__a__.foo.should == 7
  end

  pending "can be declared for a class variable" do
    @@a = "hi"
    def @@a.foo
      8
    end
    @@a.foo.should == 8
  end

  pending "can be declared with an empty method body" do
    class DefSpec
      def self.foo;end
    end
    DefSpec.foo.should == nil
  end

  pending "can be redefined" do
    obj = Object.new
    def obj.==(other)
      1
    end
    (obj==1).should == 1
    def obj.==(other)
      2
    end
    (obj==2).should == 2
  end

  ruby_version_is ""..."1.9" do
    pending "raises TypeError if frozen" do
      obj = Object.new
      obj.freeze
      lambda { def obj.foo; end }.should raise_error(TypeError)
    end
  end

  ruby_version_is "1.9" do
    pending "raises RuntimeError if frozen" do
      obj = Object.new
      obj.freeze
      lambda { def obj.foo; end }.should raise_error(RuntimeError)
    end
  end
end

describe "Redefining a singleton method" do
  pending "does not inherit a previously set visibility " do
    o = Object.new

    class << o; private; def foo; end; end;

    class << o; should have_private_instance_method(:foo); end

    class << o; def foo; end; end;

    class << o; should_not have_private_instance_method(:foo); end
    class << o; should have_instance_method(:foo); end

  end
end

describe "Redefining a singleton method" do
  pending "does not inherit a previously set visibility " do
    o = Object.new

    class << o; private; def foo; end; end;

    class << o; should have_private_instance_method(:foo); end

    class << o; def foo; end; end;

    class << o; should_not have_private_instance_method(:foo); end
    class << o; should have_instance_method(:foo); end

  end
end

describe "A method defined with extreme default arguments" do
  pending "can redefine itself when the default is evaluated" do
    class DefSpecs
      def foo(x = (def foo; "hello"; end;1));x;end
    end

    d = DefSpecs.new
    d.foo(42).should == 42
    d.foo.should == 1
    d.foo.should == 'hello'
  end

  pending "may use an fcall as a default" do
    def foo(x = caller())
      x
    end
    foo.shift.should be_kind_of(String)
  end

  it "evaluates the defaults in the method's scope" do
    def foo(x = ($foo_self = self; nil)); end
    foo
    $foo_self.should == self
  end

  it "may use preceding arguments as defaults" do
    def foo(obj, width=obj.length)
      width
    end
    foo('abcde').should == 5
  end

  it "may use a lambda as a default" do
    def foo(output = 'a', prc = lambda {|n| output * n})
      prc.call(5)
    end
    foo.should == 'aaaaa'
  end
end

describe "A singleton method defined with extreme default arguments" do
  pending "may use a method definition as a default" do
    $__a = "hi"
    def $__a.foo(x = (def $__a.foo; "hello"; end;1));x;end

    $__a.foo(42).should == 42
    $__a.foo.should == 1
    $__a.foo.should == 'hello'
  end

  pending "may use an fcall as a default" do
    a = "hi"
    def a.foo(x = caller())
      x
    end
    a.foo.shift.should be_kind_of(String)
  end

  pending "evaluates the defaults in the singleton scope" do
    a = "hi"
    def a.foo(x = ($foo_self = self; nil)); 5 ;end
    a.foo
    $foo_self.should == a
  end

  pending "may use preceding arguments as defaults" do
    a = 'hi'
    def a.foo(obj, width=obj.length)
      width
    end
    a.foo('abcde').should == 5
  end

  pending "may use a lambda as a default" do
    a = 'hi'
    def a.foo(output = 'a', prc = lambda {|n| output * n})
      prc.call(5)
    end
    a.foo.should == 'aaaaa'
  end
end

describe "A method definition inside a metaclass scope" do
  pending "can create a class method" do
    class DefSpecSingleton
      class << self
        def a_class_method;self;end
      end
    end

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

  ruby_version_is ""..."1.9" do
    pending "raises TypeError if frozen" do
      obj = Object.new
      obj.freeze

      class << obj
        lambda { def foo; end }.should raise_error(TypeError)
      end
    end
  end

  ruby_version_is "1.9" do
    pending "raises RuntimeError if frozen" do
      obj = Object.new
      obj.freeze

      class << obj
        lambda { def foo; end }.should raise_error(RuntimeError)
      end
    end
  end
end

describe "A nested method definition" do
  pending "creates an instance method when evaluated in an instance method" do
    class DefSpecNested
      def create_instance_method
        def an_instance_method;self;end
        an_instance_method
      end
    end

    obj = DefSpecNested.new
    obj.create_instance_method.should == obj
    obj.an_instance_method.should == obj

    other = DefSpecNested.new
    other.an_instance_method.should == other

    DefSpecNested.should have_instance_method(:an_instance_method)
  end

  pending "creates a class method when evaluated in a class method" do
    class DefSpecNested
      class << self
        def create_class_method
          def a_class_method;self;end
          a_class_method
        end
      end
    end

    lambda { DefSpecNested.a_class_method }.should raise_error(NoMethodError)
    DefSpecNested.create_class_method.should == DefSpecNested
    DefSpecNested.a_class_method.should == DefSpecNested
    lambda { Object.a_class_method }.should raise_error(NoMethodError)
    lambda { DefSpecNested.new.a_class_method }.should raise_error(NoMethodError)
  end

  pending "creates a singleton method when evaluated in the metaclass of an instance" do
    class DefSpecNested
      def create_singleton_method
        class << self
          def a_singleton_method;self;end
        end
        a_singleton_method
      end
    end

    obj = DefSpecNested.new
    obj.create_singleton_method.should == obj
    obj.a_singleton_method.should == obj

    other = DefSpecNested.new
    lambda { other.a_singleton_method }.should raise_error(NoMethodError)
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

  pending "creates a class method when the receiver is a class" do
    DefSpecNested.instance_eval do
      def an_instance_eval_class_method;self;end
    end

    DefSpecNested.an_instance_eval_class_method.should == DefSpecNested
    lambda { Object.an_instance_eval_class_method }.should raise_error(NoMethodError)
  end
end

describe "A method definition in an eval" do
  pending "creates an instance method" do
    class DefSpecNested
      def eval_instance_method
        eval "def an_eval_instance_method;self;end", binding
        an_eval_instance_method
      end
    end

    obj = DefSpecNested.new
    obj.eval_instance_method.should == obj
    obj.an_eval_instance_method.should == obj

    other = DefSpecNested.new
    other.an_eval_instance_method.should == other

    lambda { Object.new.an_eval_instance_method }.should raise_error(NoMethodError)
  end

  pending "creates a class method" do
    class DefSpecNestedB
      class << self
        def eval_class_method
          eval "def an_eval_class_method;self;end" #, binding
          an_eval_class_method
        end
      end
    end

    DefSpecNestedB.eval_class_method.should == DefSpecNestedB
    DefSpecNestedB.an_eval_class_method.should == DefSpecNestedB

    lambda { Object.an_eval_class_method }.should raise_error(NoMethodError)
    lambda { DefSpecNestedB.new.an_eval_class_method}.should raise_error(NoMethodError)
  end

  pending "creates a singleton method" do
    class DefSpecNested
      def eval_singleton_method
        class << self
          eval "def an_eval_singleton_method;self;end", binding
        end
        an_eval_singleton_method
      end
    end

    obj = DefSpecNested.new
    obj.eval_singleton_method.should == obj
    obj.an_eval_singleton_method.should == obj

    other = DefSpecNested.new
    lambda { other.an_eval_singleton_method }.should raise_error(NoMethodError)
  end
end

describe "a method definition that sets more than one default parameter all to the same value" do
  def foo(a=b=c={})
    [a,b,c]
  end
  pending "assigns them all the same object by default" do
    foo.should == [{},{},{}]
    a, b, c = foo
    a.should eql(b)
    a.should eql(c)
  end

  it "allows the first argument to be given, and sets the rest to null" do
    foo(1).should == [1,nil,nil]
  end

  it "assigns the parameters different objects across different default calls" do
    a, b, c = foo
    d, e, f = foo
    a.should_not equal(d)
  end

  pending "only allows overriding the default value of the first such parameter in each set" do
    lambda { foo(1,2) }.should raise_error(ArgumentError)
  end

  def bar(a=b=c=1,d=2)
    [a,b,c,d]
  end

  pending "treats the argument after the multi-parameter normally" do
    bar.should == [1,1,1,2]
    bar(3).should == [3,nil,nil,2]
    bar(3,4).should == [3,nil,nil,4]
    lambda { bar(3,4,5) }.should raise_error(ArgumentError)
  end
end

describe "The def keyword" do
  describe "within a closure" do
    pending "looks outside the closure for the visibility" do
      module DefSpecsLambdaVisibility
        private

        lambda {
          def some_method; end
        }.call
      end

      DefSpecsLambdaVisibility.should have_private_instance_method("some_method")
    end
  end
end

# language_version __FILE__, "def"
