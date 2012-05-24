require File.expand_path('../../spec_helper', __FILE__)

describe "Singleton classes" do
  it "returns an empty s(:scope) when given an empty body" do
    # FXIME
    # opal_parse('class << A; end')[2].should == [:scope]
  end

  it "does not place single expressions into an s(:block)" do
    opal_parse('class << A; 1; end')[2].should == [:scope, [:lit, 1]]
  end

  it "adds multiple body expressions into a s(:block)" do
    opal_parse('class << A; 1; 2; end')[2].should == [:scope, [:block, [:lit, 1], [:lit, 2]]]
  end

  it "should accept any expressions for singleton part" do
    # FIXME
    # opal_parse('class << A; end').should == [:sclass, [:const, :A], [:scope]]
    # opal_parse('class << self; end').should == [:sclass, [:self], [:scope]]
  end
end
