require File.expand_path('../../../spec_helper', __FILE__)

describe "Opal.defined?" do
  it "should return nil when given `undefined`" do
    Opal.defined?(`undefined`).should be_nil
  end

  it "should return the type of object for anything else" do
    Opal.defined?("wow").should == 'string'
    Opal.defined?(42).should == 'number'
    Opal.defined?(Object.new).should == 'object'
    Opal.defined?(nil).should == 'object'
    Opal.defined?(`null`).should == 'object'
  end
end
