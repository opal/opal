require File.expand_path('../../spec_helper', __FILE__)

describe "The while keyword" do
  it "returns an s(:while) with the given expr, body and true for head" do
    opal_parse("while 1; 2; end").should == [:while, [:lit, 1], [:lit, 2], true]
  end

  it "uses an s(:block) if body has more than one statement" do
    opal_parse("while 1; 2; 3; end").should == [:while, [:lit, 1], [:block, [:lit, 2], [:lit, 3]], true]
  end

  it "treats the prefix while statement just like a regular while statement" do
    opal_parse("1 while 2").should == [:while, [:lit, 2], [:lit, 1], true]
  end
end
