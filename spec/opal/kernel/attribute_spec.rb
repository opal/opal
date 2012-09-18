class AttributeSpec
  attr_accessor :foo, :bar
  attr_reader :first_name, :baz

  def initialize
    @foo = 'adam'
    @bar = 42
    @baz = 3.142
    @buz = 'omg'
  end

  def baz?
    'should not return this one'
  end

  def buz?
    @buz
  end
end

describe Kernel do
  before do
    @obj = AttributeSpec.new
  end

  describe "#attribute_get" do
    it "returns attribute values for simple keys" do
      @obj.attribute_get(:foo).should == 'adam'
      @obj.attribute_get(:bar).should == 42
    end

    it "checks for boolean (foo?) accessors after normal getters" do
      @obj.attribute_get(:baz).should == 3.142
      @obj.attribute_get(:buz).should == 'omg'
    end

    it "returns nil for unknown attributes" do
      @obj.attribute_get(:fullname).should be_nil
      @obj.attribute_get(:pingpong).should be_nil
    end
  end
  
  describe "#attribute_set" do
    it "uses the setter for the given attribute" do
      @obj.attribute_set(:foo, 42)
      @obj.foo.should == 42

      @obj.attribute_set(:foo, 3.142)
      @obj.foo.should == 3.142
    end

    it "returns nil when setting an attribute with no setter method" do
      @obj.attribute_set(:baz, 'this should not be set')
      @obj.baz.should == 3.142
    end
  end
end