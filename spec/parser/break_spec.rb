require 'spec_helper'

describe "The break keyword" do
  it "should return s(:break) when given no args" do
    opal_parse("break").should == [:break]
  end

  it "returns s(:break) with a single arg not wrapped in s(:array)" do
    opal_parse("break 1").should == [:break, [:int, 1]]
    opal_parse("break *1").should == [:break, [:splat, [:int, 1]]]
  end

  it "returns s(:break) with an s(:array) for args size > 1" do
    opal_parse("break 1, 2").should == [:break, [:array, [:int, 1], [:int, 2]]]
    opal_parse("break 1, *2").should == [:break, [:array, [:int, 1], [:splat, [:int, 2]]]]
  end
end
