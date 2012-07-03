require 'spec_helper'

describe "The __FILE__ keyword" do
  it "should always return a s(:str) with given parser filename" do
    opal_parse("__FILE__", "foo").should == [:str, "foo"]
  end
end
