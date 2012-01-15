require File.expand_path('../../../spec_helper', __FILE__)

describe "Opal.object?" do
  it "returns true if the object is a ruby object, false otherwise" do
    Opal.object?(Object.new).should be_true
    Opal.object?([1, 2, 3]).should be_true
    Opal.object?(true).should be_true
    Opal.object?(false).should be_true
    Opal.object?(nil).should be_true

    Opal.object?(`{}`).should be_false
    Opal.object?(`new Object()`).should be_false
    Opal.object?(`null`).should be_false
    Opal.object?(`undefined`).should be_false
  end
end
