require File.expand_path('../../../spec_helper', __FILE__)

describe "Opal.typeof" do
  it "returns the javascript type of the object" do
    Opal.typeof(`null`).should == 'object'
    Opal.typeof(`undefined`).should == 'undefined'
    Opal.typeof(nil).should == 'object'
  end
end
