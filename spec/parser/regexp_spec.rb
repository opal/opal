require 'spec_helper'

describe "Regexps" do
  it "parses a regexp as a s(:lit)" do
    opal_parse("/lol/").should == [:regexp, /lol/]
  end

  it "parses regexp options" do
    opal_parse("/lol/i").should == [:regexp, /lol/i]
  end

  it "can parse regexps using %r notation" do
    opal_parse('%r(foo)').should == [:regexp, /foo/]
    opal_parse('%r(foo)i').should == [:regexp, /foo/i]
  end
end
