require 'spec_helper'

describe "The super keyword" do
  it "should return s(:zsuper) when no arguments or parans" do
    opal_parse("super").should == [:zsuper]
  end

  it "should return s(:super) for any arguments" do
    opal_parse("super 1").should == [:super, [:lit, 1]]
    opal_parse("super 1, 2").should == [:super, [:lit, 1], [:lit, 2]]
    opal_parse("super 1, *2").should == [:super, [:lit, 1], [:splat, [:lit, 2]]]
  end

  it "should always return s(:super) when parans are used" do
    opal_parse("super()").should == [:super]
    opal_parse("super(1)").should == [:super, [:lit, 1]]
    opal_parse("super(1, 2)").should == [:super, [:lit, 1], [:lit, 2]]
    opal_parse("super(1, *2)").should == [:super, [:lit, 1], [:splat, [:lit, 2]]]
  end
end
