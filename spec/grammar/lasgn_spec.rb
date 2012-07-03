require 'spec_helper'

describe "Local assignment" do
  it "returns an s(:lasgn)" do
    opal_parse("a = 1").should == [:lasgn, :a, [:lit, 1]]
    opal_parse("a = 1; b = 2").should == [:block, [:lasgn, :a, [:lit, 1]], [:lasgn, :b, [:lit, 2]]]
  end
end
