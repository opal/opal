require 'spec_helper'

describe "Parsing integers" do
  it "parses integers as a s(:int) sexp" do
    opal_parse("32").should == [:int, 32]
  end
end

describe "Parsing floats" do
  it "parses floats as a s(:float)" do
    opal_parse("3.142").should == [:float, 3.142]
  end
end
