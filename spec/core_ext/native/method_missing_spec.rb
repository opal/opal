require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../fixtures/classes', __FILE__)

describe "Native#method_missing" do
  it "forwards methods to wrapped object as native function calls" do
    NativeSpecs.new("adam").toUpperCase.should == "ADAM"
  end
end
