require 'spec_helper'

describe "The super keyword" do
  it "should return s(:zsuper) when no arguments or parans" do
    opal_parse("super").should == [:zsuper]
  end

  it "should return s(:super) for any arguments" do
    opal_parse("super 1").should == [:super, [:int, 1]]
    opal_parse("super 1, 2").should == [:super, [:int, 1], [:int, 2]]
    opal_parse("super 1, *2").should == [:super, [:int, 1], [:splat, [:int, 2]]]
  end

  it "should always return s(:super) when parans are used" do
    opal_parse("super()").should == [:super]
    opal_parse("super(1)").should == [:super, [:int, 1]]
    opal_parse("super(1, 2)").should == [:super, [:int, 1], [:int, 2]]
    opal_parse("super(1, *2)").should == [:super, [:int, 1], [:splat, [:int, 2]]]
  end
end
