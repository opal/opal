require 'support/parser_helpers'

describe "Masgn" do
  describe "with a single lhs splat" do
    it "returns a s(:masgn)" do
      parsed('*a = 1, 2').first.should == :masgn
      parsed('* = 1, 2').first.should == :masgn
    end

    it "wraps splat inside a s(:array)" do
      parsed('*a = 1, 2')[1].should == [:array, [:splat, [:lasgn, :a]]]
      parsed('* = 1, 2')[1].should == [:array, [:splat]]
    end
  end

  describe "with more than 1 lhs item" do
    it "returns a s(:masgn) " do
      parsed('a, b = 1, 2').first.should == :masgn
    end

    it "collects all lhs args into an s(:array)" do
      parsed('a, b = 1, 2')[1].should == [:array, [:lasgn, :a], [:lasgn, :b]]
      parsed('@a, @b = 1, 2')[1].should == [:array, [:iasgn, :@a], [:iasgn, :@b]]
    end

    it "supports splat parts" do
      parsed('a, *b = 1, 2')[1].should == [:array, [:lasgn, :a], [:splat, [:lasgn, :b]]]
      parsed('@a, * = 1, 2')[1].should == [:array, [:iasgn, :@a], [:splat]]
    end
  end

  describe "with a single rhs argument" do
    it "should wrap rhs in an s(:to_ary)" do
      parsed('a, b = 1')[2].should == [:to_ary, [:int, 1]]
    end
  end
end
