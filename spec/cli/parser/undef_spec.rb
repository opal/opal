require File.expand_path('../../spec_helper', __FILE__)

describe "The undef keyword" do
  it "returns s(:undef) with the argument as an s(:lit)" do
    parsed("undef a").should == [:undef, [:sym, :a]]
  end

  it "appends multiple parts onto end of list" do
    parsed("undef a, b").should == [:undef, [:sym, :a], [:sym, :b]]
  end

  it "can take symbols or fitems" do
    parsed("undef :foo").should == [:undef, [:sym, :foo]]
  end
end
