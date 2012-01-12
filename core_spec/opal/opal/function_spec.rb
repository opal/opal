require File.expand_path('../../../spec_helper', __FILE__)

describe "Opal.function?" do
  it "returns true if the object is a function, false otherwise" do
    Opal.function?(proc do; end).should be_true
    Opal.function?(`function(){}`).should be_true
    Opal.function?(nil).should be_false
    Opal.function?(Object.new).should be_false
    Opal.function?(Proc).should be_false
  end
end
