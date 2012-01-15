require File.expand_path('../../spec_helper', __FILE__)

describe "Constants" do
  it "should always become a s(:const)" do
    opal_parse("FOO").should == [:const, :FOO]
    opal_parse("BAR").should == [:const, :BAR]
  end

  it "should be returned as s(:cdecl) on assignment" do
    opal_parse("FOO = 1").should == [:cdecl, :FOO, [:lit, 1]]
    opal_parse("FOO = BAR").should == [:cdecl, :FOO, [:const, :BAR]]
  end
end
