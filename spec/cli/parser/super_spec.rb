require File.expand_path('../../spec_helper', __FILE__)

describe "The super keyword" do
  it "should return s(:super) for any arguments" do
    parsed("super 1").should == [:super, [:arglist, [:int, 1]]]
    parsed("super 1, 2").should == [:super, [:arglist, [:int, 1], [:int, 2]]]
    parsed("super 1, *2").should == [:super, [:arglist, [:int, 1], [:splat, [:int, 2]]]]
  end

  it "should set nil for args when no arguments or parans" do
    parsed("super").should == [:super, nil]
  end

  it "should always return s(:super) with :arglist when parans are used" do
    parsed("super()").should == [:super, [:arglist]]
    parsed("super(1)").should == [:super, [:arglist, [:int, 1]]]
    parsed("super(1, 2)").should == [:super, [:arglist, [:int, 1], [:int, 2]]]
    parsed("super(1, *2)").should == [:super, [:arglist, [:int, 1], [:splat, [:int, 2]]]]
  end
end
