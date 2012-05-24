File.expand_path('../../spec_helper', __FILE__)

describe "Lambda literals" do
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
end