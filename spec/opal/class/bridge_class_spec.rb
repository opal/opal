%x{
  var BridgeClassProto = function() {
    this.foo = 200;
  };

  BridgeClassProto.prototype = {
    bar: 300,
    baz: 400
  };
}

Class.bridge_class :BridgeClassSpec, `BridgeClassProto`

class BridgeClassSpec
  def get_foo
    `#{self}.foo`
  end

  def say_it
    "hello world"
  end
end

describe "Class#bridge_class" do
  it "should have a superclass of Object" do
    BridgeClassSpec.superclass.should == Object
  end

  it "should report instances as kind of bridged class" do
    obj = `new BridgeClassProto()`
    obj.class.should == BridgeClassSpec
  end

  it "should have defined instance methods present on prototype" do
    obj = `new BridgeClassProto()`
    obj.get_foo.should == 200
    obj.say_it.should == "hello world"
  end
end
