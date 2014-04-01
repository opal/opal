require 'cli/spec_helper'

describe "The while keyword" do
  it "returns an s(:while) with the given expr, body and true for head" do
    parsed("while 1; 2; end").should == [:while, [:int, 1], [:int, 2]]
  end

  it "uses an s(:block) if body has more than one statement" do
    parsed("while 1; 2; 3; end").should == [:while, [:int, 1], [:block, [:int, 2], [:int, 3]]]
  end

  it "treats the prefix while statement just like a regular while statement" do
    parsed("1 while 2").should == [:while, [:int, 2], [:int, 1]]
  end
end
