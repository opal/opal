require File.expand_path('../../spec_helper', __FILE__)

describe "The break keyword" do
  it "should return s(:break) when given no args" do
    opal_parse("break").should == [:break]
  end

  it "returns s(:break) with a single arg not wrapped in s(:array)" do
    opal_parse("break 1").should == [:break, [:lit, 1]]
    opal_parse("break *1").should == [:break, [:splat, [:lit, 1]]]
  end

  it "returns s(:break) with an s(:array) for args size > 1" do
    opal_parse("break 1, 2").should == [:break, [:array, [:lit, 1], [:lit, 2]]]
    opal_parse("break 1, *2").should == [:break, [:array, [:lit, 1], [:splat, [:lit, 2]]]]
  end
end
