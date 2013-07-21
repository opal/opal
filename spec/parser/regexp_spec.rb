require 'spec_helper'

describe "Regexps" do
  it "parses a regexp as a s(:lit)" do
    opal_parse("/lol/").should == [:lit, /lol/]
  end

  it "parses regexp options" do
    opal_parse("/lol/i").should == [:lit, /lol/i]
  end

  it "can parse regexps using %r notation" do
    opal_parse('%r(foo)').should == [:lit, /foo/]
    opal_parse('%r(foo)i').should == [:lit, /foo/i]
  end
end
