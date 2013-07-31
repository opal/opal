require 'spec_helper'

describe "Singleton classes" do
  pending "returns an empty s(:scope) when given an empty body" do
    opal_parse('class << A; end')[2].should == [:scope]
  end

  it "does not place single expressions into an s(:block)" do
    opal_parse('class << A; 1; end')[2].should == [:scope, [:int, 1]]
  end

  it "adds multiple body expressions into a s(:block)" do
    opal_parse('class << A; 1; 2; end')[2].should == [:scope, [:block, [:int, 1], [:int, 2]]]
  end

  pending "should accept any expressions for singleton part" do
    opal_parse('class << A; end').should == [:sclass, [:const, :A], [:scope]]
    opal_parse('class << self; end').should == [:sclass, [:self], [:scope]]
  end
end

