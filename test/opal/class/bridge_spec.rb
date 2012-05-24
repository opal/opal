%x{
  var BridgePrototype = function() {
    this.foo = 200;
  }

  BridgePrototype.prototype = {
    woosh: function() {
      return 42;
    },

    kapow: function() {
      return 3.142;
    }
  };
}

BridgeClassSpec = Class.bridge(`BridgePrototype`) do
  def say_something
    "hello world"
  end

  def get_foo
    @foo
  end
end

describe "Class#bridge_class" do
  it "should make all instances of native constructor instances of class" do
    `(new BridgePrototype)`.should be_kind_of(BridgeClassSpec)
    `(new BridgePrototype)`.class.should == BridgeClassSpec
  end

  it "should define methods from block onto native prototype" do
    obj = `new BridgePrototype`
    obj.say_something.should == "hello world"
  end

  it "should give instances of class access to native properties" do
    BridgeClassSpec.new.get_foo.should == 200
  end
end