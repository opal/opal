require 'spec_helper'

describe "The and statement" do
  it "should always return s(:and)" do
    opal_parse("1 and 2").should == [:and, [:lit, 1], [:lit, 2]]
  end
end

describe "The && expression" do
  it "should always return s(:and)" do
    opal_parse("1 && 2").should == [:and, [:lit, 1], [:lit, 2]]
  end
end
