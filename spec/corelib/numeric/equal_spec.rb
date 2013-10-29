require 'spec_helper'

describe "Numeric#==" do
  it "should be true when two js Number objects are compared" do
    first = `new Number(42)`
    second = `new Number(42)`
    first.should == second
  end
end
