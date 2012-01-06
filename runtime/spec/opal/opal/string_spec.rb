require File.expand_path('../../../spec_helper', __FILE__)

describe "Opal.string?" do
  it "returns true if the object is a string" do
    Opal.string?("foo").should be_true
    Opal.string?(Object.new).should be_false
    Opal.string?(nil).should be_false
    Opal.string?(`null`).should be_false
    Opal.string?(`undefined`).should be_false
  end
end
