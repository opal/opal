require "spec_helper"

describe "Native#to_native" do
  it "returns the wrapped object" do
    NativeSpecs.new(:foo).to_native.should eq(:foo)
  end
end
