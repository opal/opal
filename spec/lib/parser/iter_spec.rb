require 'support/parser_helpers'

describe "Iters" do
  describe "Iter on a command" do
    it "the outer command call gets the iter" do
      parsed("a b do; end").should == [:call, nil, :a, [:arglist, [:call, nil, :b, [:arglist]]], [:iter, nil]]
      parsed("a 1, b do; end").should == [:call, nil, :a, [:arglist, [:int, 1], [:call, nil, :b, [:arglist]]], [:iter, nil]]
    end
  end

  describe "with no args" do
    it "has 'nil' as the args part of sexp" do
      parsed("proc do; end")[4][1].should == nil
    end
  end

  describe "with empty || args" do
    it "should have args set to nil" do
      parsed("proc do ||; end")[4][1].should == nil
    end
  end

  describe "with normal args" do
    it "adds a single s(:masgn) for 1 norm arg" do
      parsed("proc do |a|; end")[4][1].should == [:masgn, [:args, [:arg, :a]]]
    end

    it "lists multiple norm args inside a s(:masgn)" do
      parsed("proc do |a, b|; end")[4][1].should == [:masgn, [:args, [:arg, :a], [:arg, :b]]]
      parsed("proc do |a, b, c|; end")[4][1].should == [:masgn, [:args, [:arg, :a], [:arg, :b], [:arg, :c]]]
    end
  end

  describe "with splat arg" do
    it "adds a s(:masgn) for the s(:restarg) even if its the only arg" do
      parsed("proc do |*a|; end")[4][1].should == [:masgn, [:args, [:restarg, :a]]]
      parsed("proc do |a, *b|; end")[4][1].should == [:masgn, [:args, [:arg, :a], [:restarg, :b]]]
    end
  end

  describe "with opt args" do
    it "adds a s(:optarg) arg each optional argument" do
      parsed("proc do |a = 1|; end")[4][1].should == [:masgn, [:args, [:optarg, :a, [:int, 1]]]]
      parsed("proc do |a = 1, b = 2|; end")[4][1].should == [:masgn, [:args, [:optarg, :a, [:int, 1]], [:optarg, :b, [:int, 2]]]]
    end

    it "should add args in the direct order" do
      parsed("proc do |a, b = 1|; end")[4][1].should == [:masgn, [:args, [:arg, :a], [:optarg, :b, [:int, 1]]]]
      parsed("proc do |b = 1, *c|; end")[4][1].should == [:masgn, [:args, [:optarg, :b, [:int, 1]], [:restarg, :c]]]
      parsed("proc do |b = 1, &c|; end")[4][1].should == [:masgn, [:args, [:optarg, :b, [:int, 1]], [:block_pass, [:lasgn, :c]]]]
    end
  end

  describe "with block arg" do
    it "should add block arg with s(:block_pass) wrapping s(:lasgn) prefix" do
      parsed("proc do |&a|; end")[4][1].should == [:masgn, [:args, [:block_pass, [:lasgn, :a]]]]
    end
  end
end
