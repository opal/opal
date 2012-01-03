require File.expand_path('../../spec_helper', __FILE__)

describe "Block statements" do
  it "should return the direct expression if only one expresssion in block" do
    opal_parse("42").should == [:lit, 42]
  end

  it "should return an s(:block) with all expressions appended for > 1 expression" do
    opal_parse("42; 43").should == [:block, [:lit, 42], [:lit, 43]]
    opal_parse("42; 43\n44").should == [:block, [:lit, 42], [:lit, 43], [:lit, 44]]
  end
end
