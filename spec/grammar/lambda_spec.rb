File.expand_path('../../spec_helper', __FILE__)

describe "Lambda literals" do
  it "should parse with either do/end construct or curly braces" do
    opal_parse("-> {}").first.should == :iter
    opal_parse("-> do; end").first.should == :iter
  end

  it "should parse as a call to 'lambda' with the lambda body as a block" do
    opal_parse("-> {}").should == [:iter, [:call, nil, :lambda, [:arglist]], nil]
  end

  describe "with no args" do
    it "should accept no args" do
      opal_parse("-> {}")[2].should == nil
    end
  end

  describe "with normal args" do
    it "adds a single s(:lasgn) for 1 norm arg" do
      opal_parse("->(a) {}")[2].should == [:lasgn, :a]
    end

    it "lists multiple norm args inside a s(:masgn)" do
      opal_parse("-> (a, b) {}")[2].should == [:masgn, [:array, [:lasgn, :a], [:lasgn, :b]]]
      opal_parse("-> (a, b, c) {}")[2].should == [:masgn, [:array, [:lasgn, :a], [:lasgn, :b], [:lasgn, :c]]]
    end
  end

  describe "with optional braces" do
    it "parses normal args" do
      opal_parse("-> a {}")[2].should == [:lasgn, :a]
      opal_parse("-> a, b {}")[2].should == [:masgn, [:array, [:lasgn, :a], [:lasgn, :b]]]
    end

    it "parses splat args" do
      opal_parse("-> *a {}")[2].should == [:masgn, [:array, [:splat, [:lasgn, :a]]]]
      opal_parse("-> a, *b {}")[2].should == [:masgn, [:array, [:lasgn, :a], [:splat, [:lasgn, :b]]]]
    end

    it "parses opt args" do
      opal_parse("-> a = 1 {}")[2].should == [:masgn, [:array, [:lasgn, :a], [:block, [:lasgn, :a, [:lit, 1]]]]]
      opal_parse("-> a = 1, b = 2 {}")[2].should == [:masgn, [:array, [:lasgn, :a], [:lasgn, :b], [:block, [:lasgn, :a, [:lit, 1]], [:lasgn, :b, [:lit, 2]]]]]
    end

    it "parses block args" do
      opal_parse("-> &a {}")[2].should == [:masgn, [:array, [:block_pass, [:lasgn, :a]]]]
    end
  end

  describe "with body statements" do
    it "should be nil when no statements given" do
      opal_parse("-> {}")[3].should == nil
    end

    it "should be the single sexp when given one statement" do
      opal_parse("-> { 42 }")[3].should == [:lit, 42]
    end

    it "should wrap multiple statements into a s(:block)" do
      opal_parse("-> { 42; 3.142 }")[3].should == [:block, [:lit, 42], [:lit, 3.142]]
    end
  end
end