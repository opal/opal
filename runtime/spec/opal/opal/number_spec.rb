require File.expand_path('../../../spec_helper', __FILE__)

describe "Opal.number?" do
  it "returns true if the object is a number" do
    Opal.number?(42).should be_true
    Opal.number?(Object.new).should be_false
    Opal.number?(nil).should be_false
    Opal.number?(`null`).should be_false
    Opal.number?(`undefined`).should be_false
  end
end
