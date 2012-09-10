require 'spec_helper'

describe "The __LINE__ keyword" do
  it "should always return a literal number of the current line" do
    opal_parse("__LINE__").should == [:lit, 1]
    opal_parse("\n__LINE__").should == [:lit, 2]
  end
end
