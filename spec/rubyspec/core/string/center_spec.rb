# -*- encoding: utf-8 -*-
require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../fixtures/classes.rb', __FILE__)

describe "String#center with length, padding" do
  it "returns a new string of specified length with self centered and padded with padstr" do
    "one".center(9, '.').should       == "...one..."
    "hello".center(20, '123').should  == "1231231hello12312312"
    "middle".center(13, '-').should   == "---middle----"

    "".center(1, "abcd").should == "a"
    "".center(2, "abcd").should == "aa"
    "".center(3, "abcd").should == "aab"
    "".center(4, "abcd").should == "abab"
    "".center(6, "xy").should == "xyxxyx"
    "".center(11, "12345").should == "12345123451"

    "|".center(2, "abcd").should == "|a"
    "|".center(3, "abcd").should == "a|a"
    "|".center(4, "abcd").should == "a|ab"
    "|".center(5, "abcd").should == "ab|ab"
    "|".center(6, "xy").should == "xy|xyx"
    "|".center(7, "xy").should == "xyx|xyx"
    "|".center(11, "12345").should == "12345|12345"
    "|".center(12, "12345").should == "12345|123451"

    "||".center(3, "abcd").should == "||a"
    "||".center(4, "abcd").should == "a||a"
    "||".center(5, "abcd").should == "a||ab"
    "||".center(6, "abcd").should == "ab||ab"
    "||".center(8, "xy").should == "xyx||xyx"
    "||".center(12, "12345").should == "12345||12345"
    "||".center(13, "12345").should == "12345||123451"
  end

  it "pads with whitespace if no padstr is given" do
    "two".center(5).should    == " two "
    "hello".center(20).should == "       hello        "
  end

  it "returns self if it's longer than or as long as the specified length" do
    "".center(0).should == ""
    "".center(-1).should == ""
    "hello".center(4).should == "hello"
    "hello".center(-1).should == "hello"
    "this".center(3).should == "this"
    "radiology".center(8, '-').should == "radiology"
  end
end
