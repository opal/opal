require 'spec_helper'

describe "Instance variable assignment" do
  it "always returns an s(:iasgn)" do
    opal_parse("@a = 1").should == [:iasgn, :@a, [:int, 1]]
    opal_parse("@A = 1").should == [:iasgn, :@A, [:int, 1]]
    opal_parse("@class = 1").should == [:iasgn, :@class, [:int, 1]]
  end
end
