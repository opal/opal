require File.expand_path('../../../spec_helper', __FILE__)

describe "Opal.null?" do
  it "returns true if the given object is null, false otherwise" do
    Opal.null?(`null`).should be_true
    Opal.null?(`undefined`).should be_false
    Opal.null?(nil).should be_false
    Opal.null?(Object.new).should be_false
  end
end
