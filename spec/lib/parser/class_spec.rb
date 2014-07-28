require 'support/parser_helpers'

describe "The class keyword" do
  it "returns an empty s(:block) when given an empty body" do
    parsed('class A; end').should == [:class, [:const, :A], nil, [:block]]
  end

  it "does not place single expressions into a s(:block)" do
    parsed('class A; 1; end').should == [:class, [:const, :A], nil, [:int, 1]]
  end

  it "adds multiple body expressions into a s(:block)" do
    parsed('class A; 1; 2; end').should == [:class, [:const, :A], nil, [:block, [:int, 1], [:int, 2]]]
  end

  it "uses nil as a placeholder when no superclass is given" do
    parsed('class A; end')[2].should == nil
  end

  it "reflects the given superclass" do
    parsed('class A < B; end')[2].should == [:const, :B]
  end

  it "should accept just a constant for the class name" do
    parsed('class A; end')[1].should == [:const, :A]
  end

  it "should accept a prefix constant for the class name" do
    parsed('class ::A; end')[1].should == [:colon3, :A]
  end

  it "should accept a nested constant for the class name" do
    parsed('class A::B; end')[1].should == [:colon2, [:const, :A], :B]
  end
end
