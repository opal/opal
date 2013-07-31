require 'spec_helper'

describe "Global variables" do
  it "should be returned as s(:gvar)" do
    opal_parse("$foo").should == [:gvar, :$foo]
    opal_parse("$:").should == [:gvar, :$:]
  end

  it "should return s(:gasgn) on assignment" do
    opal_parse("$foo = 1").should == [:gasgn, :$foo, [:int, 1]]
    opal_parse("$: = 1").should == [:gasgn, :$:, [:int, 1]]
  end
end
