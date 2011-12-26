require File.expand_path('../../spec_helper', __FILE__)

describe "The defined? keyword for literals" do
  it "returns 'self' for self" do
    ret = defined?(self)
    ret.should == "self"
  end

  it "returns 'nil' for nil" do
    ret = defined?(nil)
    ret.should == "nil"
  end

  it "returns 'true' for true" do
    ret = defined?(true)
    ret.should == "true"
  end

  it "returns 'false' for false" do
    ret = defined?(false)
    ret.should == "false"
  end
end
