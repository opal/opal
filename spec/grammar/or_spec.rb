require 'spec_helper'

describe "The or statement" do
  it "should always return s(:or)" do
    opal_parse("1 or 2").should == [:or, [:lit, 1], [:lit, 2]]
  end
end

describe "The || expression" do
  it "should always return s(:or)" do
    opal_parse("1 || 2").should == [:or, [:lit, 1], [:lit, 2]]
  end
end
