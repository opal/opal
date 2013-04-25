require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../fixtures/classes', __FILE__)

describe "Native#==" do
  it "returns true if the wrapped objects are `===` to each other" do
    %x{
      var obj1 = {}, obj2 = {};
    }

    a = Native.new(`obj1`)
    b = Native.new(`obj1`)
    c = Native.new(`obj2`)

    (a == b).should be_true
    (a == c).should be_false
  end
end
