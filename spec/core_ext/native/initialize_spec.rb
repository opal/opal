require "spec_helper"

describe "Native#initialize" do
  it "raises an error when passed null or undefined" do
    lambda { NativeSpecs.new(`null`) }.should raise_error(Exception)
    lambda { NativeSpecs.new(`undefined`) }.should raise_error(Exception)
  end
end
