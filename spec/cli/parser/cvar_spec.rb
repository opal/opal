require File.expand_path('../../spec_helper', __FILE__)

describe "Class variables" do
  it "should always be returned as s(:cvar)" do
    opal_parse("@@foo").should == [:cvar, :@@foo]
  end

  it "should always be converted to s(:cvdecl) on assignment" do
    opal_parse("@@foo = 100").should == [:cvdecl, :@@foo, [:int, 100]]
  end
end
