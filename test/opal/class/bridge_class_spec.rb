%x{
  var BridgeClassProto = function() {
    this.foo = 200;
  };

  BridgeClassProto.prototype = {
    bar: 300,
    baz: 400
  };
}

class BridgeClassSpec < `BridgeClassProto`
  def get_foo
    `this.foo`
  end

  def say_it
    "hello world"
  end
end

describe "Bridging native prototypes to a class" do
  it "should have a superclass of Object" do
    BridgeClassSpec.superclass.should == Object
  end

  it "should report instances as kind of bridged class" do
    obj = `new BridgeClassProto()`
    obj.should be_kind_of(BridgeClassSpec)
  end

  it "should have defined instance methods present on prototype" do
    obj = `new BridgeClassProto()`
    obj.get_foo.should == 200
    obj.say_it.should == "hello world"
  end
end