require File.expand_path('../../spec_helper', __FILE__)

describe "The break keyword" do
  it "should return s(:break) when given no args" do
    parsed("break").should == [:break]
  end

  it "returns s(:break) with a single arg not wrapped in s(:array)" do
    parsed("break 1").should == [:break, [:int, 1]]
    parsed("break *1").should == [:break, [:splat, [:int, 1]]]
  end

  it "returns s(:break) with an s(:array) for args size > 1" do
    parsed("break 1, 2").should == [:break, [:array, [:int, 1], [:int, 2]]]
    parsed("break 1, *2").should == [:break, [:array, [:int, 1], [:splat, [:int, 2]]]]
  end
end
