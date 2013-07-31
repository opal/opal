require 'spec_helper'

describe "The module keyword" do
  it "returns a plain s(:scope) when given an empty body" do
    opal_parse('module A; end').should == [:module, :A, [:scope]]
  end

  it "does not place single expressions into a s(:block)" do
    opal_parse('module A; 1; end').should == [:module, :A, [:scope, [:int, 1]]]
  end

  it "adds multiple body expressions into a s(:block)" do
    opal_parse('module A; 1; 2; end').should == [:module, :A, [:scope, [:block, [:int, 1], [:int, 2]]]]
  end

  it "should accept just a constant for the module name" do
    opal_parse('module A; end')[1].should == :A
  end

  it "should accept a prefix constant for the module name" do
    opal_parse('module ::A; end')[1].should == [:colon3, :A]
  end

  it "should accepts a nested constant for the module name" do
    opal_parse('module A::B; end')[1].should == [:colon2, [:const, :A], :B]
  end
end
