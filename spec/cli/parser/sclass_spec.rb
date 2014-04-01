require 'cli/spec_helper'

describe "Singleton classes" do
  it "returns an empty s(:block) when given an empty body" do
    parsed('class << A; end')[2].should == [:block]
  end

  it "does not place single expressions into an s(:block)" do
    parsed('class << A; 1; end')[2].should == [:int, 1]
  end

  it "adds multiple body expressions into a s(:block)" do
    parsed('class << A; 1; 2; end')[2].should == [:block, [:int, 1], [:int, 2]]
  end

  it "should accept any expressions for singleton part" do
    parsed('class << A; end').should == [:sclass, [:const, :A], [:block]]
    parsed('class << self; end').should == [:sclass, [:self], [:block]]
  end
end

