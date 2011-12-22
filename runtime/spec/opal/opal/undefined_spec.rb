require File.expand_path('../../../spec_helper', __FILE__)

describe "Opal.undefined?" do
  it "returns true if the arg is undefined, false otherwise" do
    Opal.undefined?(`undefined`).should be_true
    Opal.undefined?(Object.new).should be_false
    Opal.undefined?(nil).should be_false
    Opal.undefined?(`null`).should be_false
  end
end
