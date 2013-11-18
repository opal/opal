require 'spec_helper'

$OPAL_TOP_LEVEL_OBJECT = self

def self.some_main_method
  3.142
end

def some_top_level_method_is_defined
  42
end

describe "Defining normal methods at the top level" do
  it "should define them on Object, not main" do
    Object.new.some_top_level_method_is_defined.should == 42
  end
end

describe "Defining singleton methods on main" do
  it "should define it on main directly" do
    $OPAL_TOP_LEVEL_OBJECT.some_main_method.should == 3.142
  end

  it "should not define the method for all Objects" do
    lambda { Object.new.some_main_method }.should raise_error(NoMethodError)
  end
end
