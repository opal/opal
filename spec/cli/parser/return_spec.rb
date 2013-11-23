require File.expand_path('../../spec_helper', __FILE__)

describe "The return keyword" do
  it "should return s(:return) when given no arguments" do
    opal_parse("return").should == [:return]
  end

  it "returns s(:return) with the direct argument when given one argument" do
    opal_parse("return 1").should == [:return, [:int, 1]]
    opal_parse("return *2").should == [:return, [:splat, [:int, 2]]]
  end

  it "returns s(:return) with an s(:array) when args size > 1" do
    opal_parse("return 1, 2").should == [:return, [:array, [:int, 1], [:int, 2]]]
    opal_parse("return 1, *2").should == [:return, [:array, [:int, 1], [:splat, [:int, 2]]]]
  end
end
