require 'spec_helper'

class MyStringSubclass < String
  attr_reader :v
  def initialize(s, v)
    super(s)
    @v = v
  end
end

describe "String subclassing" do
  it "should call initialize for subclasses" do
    c = MyStringSubclass.new('s', 5)
    [c, c.v].should == ['s', 5]
  end
end
