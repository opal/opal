require File.expand_path('../../spec_helper', __FILE__)

describe "Block statements" do
  it "should return the direct expression if only one expresssion in block" do
    opal_parse("42").should == [:int, 42]
  end

  it "should return an s(:block) with all expressions appended for > 1 expression" do
    opal_parse("42; 43").should == [:block, [:int, 42], [:int, 43]]
    opal_parse("42; 43\n44").should == [:block, [:int, 42], [:int, 43], [:int, 44]]
  end
end
