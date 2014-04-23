require 'cli/spec_helper'

describe "Lambda literals" do
  it "should parse with either do/end construct or curly braces" do
    parsed("-> {}").first.should == :call
    parsed("-> do; end").first.should == :call
  end

  it "should parse as a call to 'lambda' with the lambda body as a block" do
    parsed("-> {}").should == [:call, nil, :lambda, [:arglist], [:iter, nil]]
  end

  describe "with no args" do
    it "should accept no args" do
      parsed("-> {}")[4][1].should == nil
    end
  end

  describe "with normal args" do
    it "adds a single s(:lasgn) for 1 norm arg" do
      parsed("->(a) {}")[4][1].should == [:lasgn, :a]
    end

    it "lists multiple norm args inside a s(:masgn)" do
      parsed("-> (a, b) {}")[4][1].should == [:masgn, [:array, [:lasgn, :a], [:lasgn, :b]]]
      parsed("-> (a, b, c) {}")[4][1].should == [:masgn, [:array, [:lasgn, :a], [:lasgn, :b], [:lasgn, :c]]]
    end
  end

  describe "with optional braces" do
    it "parses normal args" do
      parsed("-> a {}")[4][1].should == [:lasgn, :a]
      parsed("-> a, b {}")[4][1].should == [:masgn, [:array, [:lasgn, :a], [:lasgn, :b]]]
    end

    it "parses splat args" do
      parsed("-> *a {}")[4][1].should == [:masgn, [:array, [:splat, [:lasgn, :a]]]]
      parsed("-> a, *b {}")[4][1].should == [:masgn, [:array, [:lasgn, :a], [:splat, [:lasgn, :b]]]]
    end

    it "parses opt args" do
      parsed("-> a = 1 {}")[4][1].should == [:masgn, [:array, [:lasgn, :a], [:block, [:lasgn, :a, [:int, 1]]]]]
      parsed("-> a = 1, b = 2 {}")[4][1].should == [:masgn, [:array, [:lasgn, :a], [:lasgn, :b], [:block, [:lasgn, :a, [:int, 1]], [:lasgn, :b, [:int, 2]]]]]
    end

    it "parses block args" do
      parsed("-> &a {}")[4][1].should == [:masgn, [:array, [:block_pass, [:lasgn, :a]]]]
    end
  end

  describe "with body statements" do
    it "should be nil when no statements given" do
      parsed("-> {}")[4][2].should == nil
    end

    it "should be the single sexp when given one statement" do
      parsed("-> { 42 }")[4][2].should == [:int, 42]
    end

    it "should wrap multiple statements into a s(:block)" do
      parsed("-> { 42; 3.142 }")[4][2].should == [:block, [:int, 42], [:float, 3.142]]
    end
  end
end
