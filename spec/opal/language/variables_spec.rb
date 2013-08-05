require 'spec_helper'

describe "Mass assignment" do
  it "supports setting attributes on lhs" do
    object = Class.new { attr_accessor :foo, :bar }.new

    object.foo, object.bar = 100, 200

    object.foo.should == 100
    object.bar.should == 200
  end

  it "supports setting []= on lhs" do
    hash = {}
    hash[:foo], hash[:bar] = 3.142, 42

    hash[:foo].should == 3.142
    hash[:bar].should == 42
  end
end
