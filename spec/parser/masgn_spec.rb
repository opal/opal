require 'spec_helper'

describe "Masgn" do
  describe "with a single lhs splat" do
    it "returns a s(:masgn)" do
      opal_parse('*a = 1, 2').first.should == :masgn
      opal_parse('* = 1, 2').first.should == :masgn
    end

    it "wraps splat inside a s(:array)" do
      opal_parse('*a = 1, 2')[1].should == [:array, [:splat, [:lasgn, :a]]]
      opal_parse('* = 1, 2')[1].should == [:array, [:splat]]
    end
  end

  describe "with more than 1 lhs item" do
    it "returns a s(:masgn) " do
      opal_parse('a, b = 1, 2').first.should == :masgn
    end

    it "collects all lhs args into an s(:array)" do
      opal_parse('a, b = 1, 2')[1].should == [:array, [:lasgn, :a], [:lasgn, :b]]
      opal_parse('@a, @b = 1, 2')[1].should == [:array, [:iasgn, :@a], [:iasgn, :@b]]
    end

    it "supports splat parts" do
      opal_parse('a, *b = 1, 2')[1].should == [:array, [:lasgn, :a], [:splat, [:lasgn, :b]]]
      opal_parse('@a, * = 1, 2')[1].should == [:array, [:iasgn, :@a], [:splat]]
    end
  end

  describe "with a single rhs argument" do
    it "should wrap rhs in an s(:to_ary)" do
      opal_parse('a, b = 1')[2].should == [:to_ary, [:int, 1]]
    end
  end
end
