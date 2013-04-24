require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../fixtures/classes', __FILE__)

describe "Native#method_missing" do
  before do
    @obj = NativeSpecs::OBJ
  end

  it "returns values from the native object" do
    @obj.property.should == 42
  end

  it "returns nil for a non-existant property" do
    @obj.doesnt_exist.should == nil
  end

  it "forwards methods to wrapped object as native function calls" do
    @obj.simple.should == "foo"
  end

  it "calls functions with native object as context" do
    @obj.context_check.should be_true
  end

  it "passes each argument to native function" do
    @obj.check_args(1, 2, 3).should == [1, 2, 3]
  end
end
