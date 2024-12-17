# backtick_javascript: true

require 'spec_helper'

%x{
  var bridge_class_demo = function(){};
  bridge_class_demo.prototype.$foo = function() { return "bar" };
}
class TopBridgedClassDemo < `bridge_class_demo`
  def some_bridged_method
    [1, 2, 3]
  end

  def method_missing(name, *args, &block)
    return :catched if name == :catched_by_method_missing
    super
  end
end

describe "Bridged Classes" do
  describe "Passing native constructor to class keyword" do
    before do
      @bridged = ::TopBridgedClassDemo
      @instance = `new bridge_class_demo()`
    end

    it "should expose the given class at the top level scope" do
      @bridged.should be_kind_of(Class)
    end

    it "gives the class the correct name" do
      @bridged.name.should == "TopBridgedClassDemo"
    end

    it "should have all BasicObject methods defined" do
      @instance.should respond_to(:instance_eval)
      @bridged.new.should respond_to(:==)
    end

    it "should have all Object methods defined" do
      @instance.should respond_to(:class)
      @bridged.new.should respond_to(:singleton_class)
    end

    it "instances of class should be able to call native ruby methods" do
      @instance.foo.should == "bar"
      @bridged.new.foo.should == "bar"
    end

    it "allows new methods to be defined on the bridged prototype" do
      @instance.some_bridged_method.should == [1, 2, 3]
      @bridged.new.some_bridged_method.should == [1, 2, 3]
    end
  end

  describe ".instance_methdods" do
    it "should report methods for class" do
      Array.instance_methods(false).should include(:shift)
    end

    it "should not include methods donated from Object/Kernel" do
      Array.instance_methods(false).should_not include(:class)
    end

    it "should not include methods donated from BasicObject" do
      Array.instance_methods(false).should_not include(:__send__)
      Array.instance_methods(false).should_not include(:send)
    end
  end

  describe '#method_missing' do
    it 'works' do
      lambda { @instance.not_catched_by_method_missing }.should raise_error(NoMethodError)
      @instance.catched_by_method_missing.should == :catched
    end
  end
end

class ModularizedBridgeClass
  def something
    'different module'
  end
end

%x{
  var bridge_class_demo_module = function(){};
  bridge_class_demo_module.prototype.$foo = function() { return "foobar" };
}

module BridgeModule
  class ModularizedBridgeClass < `bridge_class_demo_module`
    def some_bridged_method
      [4, 5, 6]
    end
  end
end

describe 'Bridged classes in different modules' do
  before do
    @bridged = BridgeModule::ModularizedBridgeClass
    @instance = `new bridge_class_demo_module()`
  end

  it "should expose the given class not at the top level scope" do
    @bridged.should be_kind_of(Class)
  end

  it 'should not disturb an existing class at the top level scope' do
    ModularizedBridgeClass.new.something.should == 'different module'
  end

  it "gives the class the correct name" do
    @bridged.name.should == "BridgeModule::ModularizedBridgeClass"
  end

  it "instances of class should be able to call native ruby methods" do
    @instance.foo.should == "foobar"
    @bridged.new.foo.should == "foobar"
  end

  it "allows new methods to be defined on the bridged prototype" do
    @instance.some_bridged_method.should == [4, 5, 6]
    @bridged.new.some_bridged_method.should == [4, 5, 6]
  end
end

%x{
  var counter = 0;
  var reset_counter = function() { counter = 0; };
  var bridge_class_with_constructor = function() { counter++; };
}

class BridgedLevel0 < `bridge_class_with_constructor`; end
class BridgedLevel1 < BridgedLevel0; end
class BridgedLevel2 < BridgedLevel1; end
class BridgedLevel3 < BridgedLevel2; end

describe 'Inheritance with bridged classes' do
  it 'should call a JS constructor on level 0' do
    `reset_counter()`
    BridgedLevel0.new
    `counter`.should == 1
  end

  it 'should call a JS constructor on level 1' do
    `reset_counter()`
    BridgedLevel1.new
    `counter`.should == 1
  end

  it 'should call a JS constructor on level 2' do
    `reset_counter()`
    BridgedLevel2.new
    `counter`.should == 1
  end

  it 'should call a JS constructor on level 3' do
    `reset_counter()`
    BridgedLevel3.new
    `counter`.should == 1
  end
end

describe 'Invalid bridged classes' do
  it 'raises a TypeError when trying to extend with non-Class' do
    error_msg = /superclass must be a Class/
    -> { class TestClass < `""`;                  end }.should raise_error(TypeError, error_msg)
    -> { class TestClass < `3`;                   end }.should raise_error(TypeError, error_msg)
    -> { class TestClass < `true`;                end }.should raise_error(TypeError, error_msg)
    -> { class TestClass < `Math`;                end }.should raise_error(TypeError, error_msg)
    -> { class TestClass < `Object.create({})`;   end }.should raise_error(TypeError, error_msg)
    -> { class TestClass < `Object.create(null)`; end }.should raise_error(TypeError, error_msg)
    -> { class TestClass < Module.new;            end }.should raise_error(TypeError, error_msg)
    -> { class TestClass < BasicObject.new;       end }.should raise_error(TypeError, error_msg)
  end
end

describe 'Bridging subclassed JavaScript Classes' do
  it 'is working' do
    %x{
      class Dog { bark() { return 'wuff'; }}
      class ChowChow extends Dog { cuddle() { return 'grrrrr'; }}
    }

    class ChowChow < `ChowChow`
      def bark
        `self.bark()`
      end

      def cuddle
        `self.cuddle()`
      end
    end

    # check direct bridge
    ChowChow.new.cuddle.should == 'grrrrr'

    # check if js superclass can be reached
    ChowChow.new.bark.should == 'wuff'
  end

  it 'is kinda working with subclassed bridged classes' do
    # Lets demonstrate how that works for a simple case:

    # JS class inheriting from bridged JS class:
    %x{
      class SuperString extends String {
        constructor(arg) { super(arg); }
        travel_through_time() { return 'Hello my dear friend! Greetings from the future!'; }
      }
    }

    # build bridge:
    class RubySuperString < `SuperString`
      def travel_through_time
        `self.travel_through_time()`
      end

      def incinerate
        ''
      end
    end

    # this does work:
    RubySuperString.new.travel_through_time.should == 'Hello my dear friend! Greetings from the future!'

    # this does work too:
    RubySuperString.new.incinerate == ''

    # that too:
    %x{
      function try_access_from_javascript() {
        try {
          return (new SuperString()).$incinerate();
        } catch {
          return nil;
        }
      }
    }
    `try_access_from_javascript()`.should == ''

    # We inherited from JS String which has ::String in its prototype, can we slice?
    RubySuperString.new('123').slice(0, 9).should == "undefined"
    # Of course not, a bit weird. One must take care of such things when bridging.
    # The standard Object allocator ignores args. Usually they are handled in #initialize.

    # But we must pass the arg when allocating the object so we must overwrite ::new :
    class RubySuperString
      def self.new(arg)
        `new self.$$constructor(arg)`
      end
    end

    # can we now slice?
    RubySuperString.new('123').slice(1).should == '2'
    # Yes. Nice. But note that this is a Method from ::String!
    # The availablity of methods from another class may come as a surprise when bridging
    # Classes with bridges in its prototype chain.

    # But did we mess up prototypes? Can String maybe #travel_through_time too?
    -> {
      String.new.travel_through_time.should  == 'Hello my dear friend! Greetings from the future!'
    }.should raise_error NoMethodError
    # No. Phuu.

    # For more complicated cases "manually" adapting the protype chain may be required.
    # But we don't need to test that, because we assume that people know what they
    # are doing when they adapt prototypes.
  end
end
