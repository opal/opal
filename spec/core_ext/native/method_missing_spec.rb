require "spec_helper"

describe "Native#method_missing" do
  it "forwards methods to wrapped object as native function calls" do
    NativeSpecs.new("adam").toUpperCase.should eq("ADAM")
  end
end
