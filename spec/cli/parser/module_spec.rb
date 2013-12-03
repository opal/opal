require File.expand_path('../../spec_helper', __FILE__)

describe "The module keyword" do
  it "returns an empty s(:block) when given an empty body" do
    parsed('module A; end').should == [:module, [:const, :A], [:block]]
  end

  it "does not place single expressions into a s(:block)" do
    parsed('module A; 1; end').should == [:module, [:const, :A], [:int, 1]]
  end

  it "adds multiple body expressions into a s(:block)" do
    parsed('module A; 1; 2; end').should == [:module, [:const, :A], [:block, [:int, 1], [:int, 2]]]
  end

  it "should accept just a constant for the module name" do
    parsed('module A; end')[1].should == [:const, :A]
  end

  it "should accept a prefix constant for the module name" do
    parsed('module ::A; end')[1].should == [:colon3, :A]
  end

  it "should accepts a nested constant for the module name" do
    parsed('module A::B; end')[1].should == [:colon2, [:const, :A], :B]
  end
end
