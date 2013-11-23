require File.expand_path('../../spec_helper', __FILE__)

describe "The super keyword" do
  it "should return s(:super) for any arguments" do
    opal_parse("super 1").should == [:super, [:arglist, [:int, 1]]]
    opal_parse("super 1, 2").should == [:super, [:arglist, [:int, 1], [:int, 2]]]
    opal_parse("super 1, *2").should == [:super, [:arglist, [:int, 1], [:splat, [:int, 2]]]]
  end

  it "should set nil for args when no arguments or parans" do
    opal_parse("super").should == [:super, nil]
  end

  it "should always return s(:super) with :arglist when parans are used" do
    opal_parse("super()").should == [:super, [:arglist]]
    opal_parse("super(1)").should == [:super, [:arglist, [:int, 1]]]
    opal_parse("super(1, 2)").should == [:super, [:arglist, [:int, 1], [:int, 2]]]
    opal_parse("super(1, *2)").should == [:super, [:arglist, [:int, 1], [:splat, [:int, 2]]]]
  end
end
