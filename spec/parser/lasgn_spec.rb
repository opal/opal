require 'spec_helper'

describe "Local assignment" do
  it "returns an s(:lasgn)" do
    opal_parse("a = 1").should == [:lasgn, :a, [:int, 1]]
    opal_parse("a = 1; b = 2").should == [:block, [:lasgn, :a, [:int, 1]], [:lasgn, :b, [:int, 2]]]
  end
end
