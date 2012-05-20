require File.expand_path('../../spec_helper', __FILE__)

describe "Hash literals" do
  it "without any assocs should return an empty hash sexp" do
    opal_parse("{}").should == [:hash]
  end

  it "adds each assoc pair as individual args onto sexp" do
    opal_parse("{1 => 2}").should == [:hash, [:lit, 1], [:lit, 2]]
    opal_parse("{1 => 2, 3 => 4}").should == [:hash, [:lit, 1], [:lit, 2], [:lit, 3], [:lit, 4]]
  end

  it "supports 1.9 style hash keys" do
    opal_parse("{ a: 1 }").should == [:hash, [:lit, :a], [:lit, 1]]
    opal_parse("{ a: 1, b: 2 }").should == [:hash, [:lit, :a], [:lit, 1], [:lit, :b], [:lit, 2]]
  end
end
