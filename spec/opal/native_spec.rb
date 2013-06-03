require 'spec_helper'

%x{
  var obj = {
    property: 42,

    simple: function() {
      return 'foo';
    },

    context_check: function() {
      return this === obj;
    },

    check_args: function(a, b, c) {
      return [a, b, c];
    },

    array: [1, 2, 3, 4],

    child_object: {
      grand_child: 100
    }
  };
}

NATIVE_OBJECT_SPEC = `obj`

describe "Native objects" do
  before do
    @obj = NATIVE_OBJECT_SPEC
  end

  describe "accessing a null/undefined property" do
    it "returns nil" do
      @obj.doesnt_exist.should == nil
    end
  end

  describe "with a mid ending with '='" do
    it "sets the value on the property" do
      @obj.set_property = 100
      @obj.set_property.should == 100

      @obj.set_property = [1, 2, 3]
      @obj.set_property.should == [1, 2, 3]
    end
  end

  describe "accessing a property" do
    it "returns values from the native object" do
      @obj.property.should == 42
    end

    it "returns an array without wrapping" do
      @obj.array.should == [1, 2, 3, 4]
    end

  end

  describe "accessing a function property" do
    it "forwards methods to wrapped object as native function calls" do
      @obj.simple.should == "foo"
    end

    it "calls functions with native object as context" do
      @obj.context_check.should be_true
    end

    it "passes each argument to native function" do
      @obj.check_args(1, 2, 3).should == [1, 2, 3]
    end

    it "tries to convert each argument with to_native if defined" do
      obj, obj2, obj3 = Object.new, Object.new, Object.new
      def obj.to_native; "foo"; end
      def obj2.to_native; 42; end

      @obj.check_args(obj, obj2, obj3).should == ["foo", 42, obj3]
    end
  end

  describe "#[]" do
    before do
      @native = %x{
        {
        foo: 'FOO',

        str: 'LOL',
        num: 42,
        on: true,
        off: false
        };
      }
    end

    it "returns a value from the native object" do
      @native['foo'].should == "FOO"
    end

    it "returns nil for a key not existing on native object" do
      @native['bar'].should be_nil
    end

    it "returns direct values for strings, numerics and booleans" do
      @native['str'].should == 'LOL'
      @native['num'].should == 42
      @native['on'].should == true
      @native['off'].should == false
    end
  end

  describe "==" do
    it "returns true if the wrapped objects are `===` to each other" do
      %x{
        var obj1 = {}, obj2 = {};
      }

      a = `obj1`
      b = `obj1`
      c = `obj2`

      (a == b).should be_true
      (a == c).should be_false
    end
  end

  describe "each" do
    describe "with an array-like object" do
      it "yields each element to block" do
        object = `{ "0": 3.142, "1": 42, "length": 2 }`
        result = []

        object.each { |obj| result << obj }
        result.should == [3.142, 42]
      end

      it "yields null and undefined values as nil" do
        object = `{length: 3, 0: null, 1: undefined}`
        result = []

        object.each { |obj| result << obj }
        result.should == [nil, nil, nil]
      end
    end

    describe "with a normal js object" do
      it "yields each key-value pair to the block" do
        object = `{"foo": 3.142, "bar": 42}`
        result = []

        object.each { |k, v| result << [k, v] }
        result.should == [["foo", 3.142], ["bar", 42]]
      end

      it "yields null and undefined values as nil" do
        object = `{"foo": null, "bar": undefined}`
        result = []

        object.each { |k, v| result << v }
        result.should == [nil, nil]
      end
    end
  end

  describe "#to_h" do
    it "converts a simple js object into a ruby hash" do
      object = `{"foo": true, "bar": 42}`
      hash = object.to_h

      hash.should be_kind_of(Hash)
      hash.should == {"foo" => true, "bar" => 42}
    end

    it "converts all null and undefined values to nil" do
      object = `{"a": null, "b": undefined}`
      object.to_h.should == {"a" => nil, "b" => nil}
    end
  end
end
