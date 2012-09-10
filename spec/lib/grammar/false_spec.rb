require 'spec_helper'

describe "The false keyword" do
  it "should always return s(:false)" do
    opal_parse("false").should == [:false]
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
