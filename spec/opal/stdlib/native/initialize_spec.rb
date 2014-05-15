require 'native'

describe "Native#initialize" do
  it "works when Native is included in a BasicObject" do
    basic_class = Class.new(BasicObject)
    basic_object = basic_class.new
    expect { basic_object.native? }.to raise_error(NoMethodError)

    basic_class.send :include, Native
    expect { basic_class.new(`{}`) }.not_to raise_error
  end

  it "detects a non native object" do
    object = Object.new
    expect { Native::Object.new(object) }.to raise_error(ArgumentError)
  end
end
