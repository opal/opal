require 'spec_helper'

describe "The undef keyword" do
  it "returns s(:undef) with the argument as an s(:lit)" do
    opal_parse("undef a").should == [:undef, [:lit, :a]]
  end

  it "appends multiple parts onto end of list" do
    opal_parse("undef a, b").should == [:undef, [:lit, :a], [:lit, :b]]
  end

  it "can take symbols or fitems" do
    opal_parse("undef :foo").should == [:undef, [:lit, :foo]]
  end
end
