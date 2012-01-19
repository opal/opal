require File.expand_path('../../spec_helper', __FILE__)

describe "The true keyword" do
  it "always returns s(:true)" do
    opal_parse("true").should == [:true]
  end

  it "cannot be assigned to" do
    lambda {
      opal_parse "true = 1"
    }.should raise_error(Exception)

    lambda {
      opal_parse "true = true"
    }.should raise_error(Exception)
  end
end
