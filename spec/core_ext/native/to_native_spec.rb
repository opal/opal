require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../fixtures/classes', __FILE__)

describe "Native#to_native" do
  it "returns the wrapped object" do
    NativeSpecs.new(:foo).to_native.should == :foo
  end
end
