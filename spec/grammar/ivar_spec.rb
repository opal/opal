require File.expand_path('../../spec_helper', __FILE__)

describe "Instance variables" do
  it "always return an s(:ivar)" do
    opal_parse("@a").should == [:ivar, :@a]
    opal_parse("@A").should == [:ivar, :@A]
    opal_parse("@class").should == [:ivar, :@class]
  end
end
