require File.expand_path('../../spec_helper', __FILE__)

describe "The def keyword" do
  describe "for normal definitions" do
    it "should return s(:def)" do
      opal_parse("def a; end").should == [:def, nil, :a, [:args], [:block, [:nil]]]
    end

    it "adds s(:nil) on an empty body" do
      opal_parse("def foo; end").last.should == [:block, [:nil]]
    end
  end

  describe "for singleton definitions" do
    it "should return s(:def)" do
      opal_parse("def self.a; end").should == [:def, [:self], :a, [:args], [:block, [:nil]]]
    end

    it "adds s(:nil) on an empty body" do
      opal_parse("def self.foo; end").last.should == [:block, [:nil]]
    end
  end

  describe "with normal args" do
    it "should list all args" do
      opal_parse("def foo(a); end")[3].should == [:args, :a]
      opal_parse("def foo(a, b); end")[3].should == [:args, :a, :b]
      opal_parse("def foo(a, b, c); end")[3].should == [:args, :a, :b, :c]
    end
  end

  describe "with opt args" do
    it "should list all opt args as well as block with each lasgn" do
      opal_parse("def foo(a = 1); end")[3].should == [:args, :a, [:block, [:lasgn, :a, [:int, 1]]]]
      opal_parse("def foo(a = 1, b = 2); end")[3].should == [:args, :a, :b, [:block, [:lasgn, :a, [:int, 1]], [:lasgn, :b, [:int, 2]]]]
    end

    it "should list lasgn block after all other args" do
      opal_parse("def foo(a, b = 1); end")[3].should == [:args, :a, :b, [:block, [:lasgn, :b, [:int, 1]]]]
      opal_parse("def foo(b = 1, *c); end")[3].should == [:args, :b, :"*c", [:block, [:lasgn, :b, [:int, 1]]]]
      opal_parse("def foo(b = 1, &block); end")[3].should == [:args, :b, :"&block", [:block, [:lasgn, :b, [:int, 1]]]]
    end
  end

  describe "with rest args" do
    it "should list rest args in place as a symbol with '*' prefix" do
      opal_parse("def foo(*a); end")[3].should == [:args, :"*a"]
    end

    it "uses '*' as an arg name for rest args without a name" do
      opal_parse("def foo(*); end")[3].should == [:args, :"*"]
    end
  end

  describe "with block arg" do
    it "should list block argument with the '&' prefix" do
      opal_parse("def foo(&a); end")[3].should == [:args, :"&a"]
    end
  end
end

