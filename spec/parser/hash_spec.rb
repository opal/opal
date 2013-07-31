require 'spec_helper'

describe "Hash literals" do
  it "without any assocs should return an empty hash sexp" do
    opal_parse("{}").should == [:hash]
  end

  it "adds each assoc pair as individual args onto sexp" do
    opal_parse("{1 => 2}").should == [:hash, [:int, 1], [:int, 2]]
    opal_parse("{1 => 2, 3 => 4}").should == [:hash, [:int, 1], [:int, 2], [:int, 3], [:int, 4]]
  end

  it "supports 1.9 style hash keys" do
    opal_parse("{ a: 1 }").should == [:hash, [:sym, :a], [:int, 1]]
    opal_parse("{ a: 1, b: 2 }").should == [:hash, [:sym, :a], [:int, 1], [:sym, :b], [:int, 2]]
  end
end
