require File.expand_path('../../spec_helper', __FILE__)

describe Opal::Parser do

  it "parses true keyword" do
    opal_parse("true").should == [:true]
  end

  it "true cannot be assigned to" do
    lambda {
      opal_parse "true = 1"
    }.should raise_error(Exception)
  end

  it "parses false keyword" do
    opal_parse("false").should == [:false]
  end

  it "false cannot be assigned to" do
    lambda {
      opal_parse "true = 1"
    }.should raise_error(Exception)
  end

  it "parses nil keyword" do
    opal_parse("nil").should == [:nil]
  end

  it "nil cannot be assigned to" do
    lambda {
      opal_parse "nil = 1"
    }.should raise_error(Exception)
  end

  it "parses self keyword" do
    opal_parse("self").should == [:self]
  end

  it "self cannot be assigned to" do
    lambda {
      opal_parse "self = 1"
    }.should raise_error(Exception)
  end

  it "parses __FILE__ and should always return a s(:str) with given parser filename" do
    opal_parse("__FILE__", "foo").should == [:str, "foo"]
  end

  it "parses __LINE__ and should always return a literal number of the current line" do
    opal_parse("__LINE__").should == [:int, 1]
    opal_parse("\n__LINE__").should == [:int, 2]
  end

  it "parses integers as a s(:int) sexp" do
    opal_parse("32").should == [:int, 32]
  end

  it "parses floats as a s(:float)" do
    opal_parse("3.142").should == [:float, 3.142]
  end
end
