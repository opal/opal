require File.expand_path('../../../spec_helper', __FILE__)

describe "Opal.native?" do
  it "returns true if the object is not a ruby object, false if it is" do
    Opal.native?(`{}`).should be_true
    Opal.native?(`new Object()`).should be_true
    Opal.native?(`null`).should be_true
    Opal.native?(`undefined`).should be_true

    Opal.native?(Object.new).should be_false
    Opal.native?([1, 2, 3]).should be_false
    Opal.native?(true).should be_false
    Opal.native?(false).should be_false
    Opal.native?(nil).should be_false
  end
end
