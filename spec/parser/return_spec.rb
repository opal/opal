require 'spec_helper'

describe "The return keyword" do
  it "should return s(:return) when given no arguments" do
    opal_parse("return").should == [:return]
  end

  it "returns s(:return) with the direct argument when given one argument" do
    opal_parse("return 1").should == [:return, [:lit, 1]]
    opal_parse("return *2").should == [:return, [:splat, [:lit, 2]]]
  end

  it "returns s(:return) with an s(:array) when args size > 1" do
    opal_parse("return 1, 2").should == [:return, [:array, [:lit, 1], [:lit, 2]]]
    opal_parse("return 1, *2").should == [:return, [:array, [:lit, 1], [:splat, [:lit, 2]]]]
  end
end
