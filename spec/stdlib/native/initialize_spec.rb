require 'native'

describe "Native#initialize" do
  it "works when Native is included in a BasicObject" do
    basic_class = Class.new(BasicObject)
    basic_object = basic_class.new
    lambda { basic_object.native? }.should raise_error(NoMethodError)

    basic_class.send :include, Native
    lambda { basic_class.new(`{}`) }.should_not raise_error
  end

  it "detects a non native object" do
    object = Object.new
    lambda { Native::Object.new(object) }.should raise_error(ArgumentError)
  end
end
