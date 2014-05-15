require 'spec_helper'

%x{
  var bridge_class_demo = function(){};
  bridge_class_demo.prototype.$foo = function() { return "bar" };
}

class TopBridgedClassDemo < `bridge_class_demo`
  def some_bridged_method
    [1, 2, 3]
  end
end

describe "Bridged Classes" do
  describe "Passing native constructor to class keyword" do
    before do
      @bridged = ::TopBridgedClassDemo
      @instance = `new bridge_class_demo`
    end

    it "should expose the given class at the top level scope" do
      expect(@bridged).to be_kind_of(Class)
    end

    it "gives the class the correct name" do
      expect(@bridged.name).to eq("TopBridgedClassDemo")
    end

    it "should have all BasicObject methods defined" do
      expect(@instance).to respond_to(:instance_eval)
      expect(@bridged.new).to respond_to(:==)
    end

    it "should have all Object methods defined" do
      expect(@instance).to respond_to(:class)
      expect(@bridged.new).to respond_to(:singleton_class)
    end

    it "instances of class should be able to call native ruby methods" do
      expect(@instance.foo).to eq("bar")
      expect(@bridged.new.foo).to eq("bar")
    end

    it "allows new methods to be defined on the bridged prototype" do
      expect(@instance.some_bridged_method).to eq([1, 2, 3])
      expect(@bridged.new.some_bridged_method).to eq([1, 2, 3])
    end
  end

  describe ".instance_methdods" do
    it "should report methods for class" do
      expect(Array.instance_methods).to include(:shift)
    end

    it "should not include methods donated from Object/Kernel" do
      expect(Array.instance_methods).not_to include(:class)
    end

    it "should not include methods donated from BasicObject" do
      expect(Array.instance_methods).not_to include(:__send__)
      expect(Array.instance_methods).not_to include(:send)
    end
  end
end
