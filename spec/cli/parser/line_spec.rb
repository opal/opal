require File.expand_path('../../spec_helper', __FILE__)

describe "The __LINE__ keyword" do
  it "should always return a literal number of the current line" do
    opal_parse("__LINE__").should == [:int, 1]
    opal_parse("\n__LINE__").should == [:int, 2]
  end
end
