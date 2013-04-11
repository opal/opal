require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../fixtures/classes', __FILE__)

describe "Native#to_native" do
  it "returns the wrapped object" do
    Native.new(:foo).to_native.should == :foo
  end
end
