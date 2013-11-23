require File.expand_path('../../spec_helper', __FILE__)

describe "The if keyword" do
  it "should return an s(:if) with given truthy and falsy bodies" do
    opal_parse("if 1; 2; else; 3; end").should == [:if, [:int, 1], [:int, 2], [:int, 3]]
  end

  it "uses nil as fasly body if not given else-then" do
    opal_parse("if 1; 2; end").should == [:if, [:int, 1], [:int, 2], nil]
  end

  it "is treats elsif parts as sub if expressions for else body" do
    opal_parse("if 1; 2; elsif 3; 4; else; 5; end").should == [:if, [:int, 1], [:int, 2], [:if, [:int, 3], [:int, 4], [:int, 5]]]
    opal_parse("if 1; 2; elsif 3; 4; end").should == [:if, [:int, 1], [:int, 2], [:if, [:int, 3], [:int, 4], nil]]
  end

  it "returns a simple s(:if) with nil else body for prefix if statement" do
    opal_parse("1 if 2").should == [:if, [:int, 2], [:int, 1], nil]
  end
end

describe "The ternary operator" do
  it "gets converted into an if statement with true and false parts" do
    opal_parse("1 ? 2 : 3").should == [:if, [:int, 1], [:int, 2], [:int, 3]]
  end
end
