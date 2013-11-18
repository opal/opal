# -*- encoding: utf-8 -*-
require File.expand_path('../fixtures/classes.rb', __FILE__)

describe "String#ljust" do
  it "returns a new string of specified length with self left justified and padded with padstr" do
    "hello".ljust(20, '1234').should == "hello123412341234123"

    "".ljust(1, "abcd").should == "a"
    "".ljust(2, "abcd").should == "ab"
    "".ljust(3, "abcd").should == "abc"
    "".ljust(4, "abcd").should == "abcd"
    "".ljust(6, "abcd").should == "abcdab"

    "OK".ljust(3, "abcd").should == "OKa"
    "OK".ljust(4, "abcd").should == "OKab"
    "OK".ljust(6, "abcd").should == "OKabcd"
    "OK".ljust(8, "abcd").should == "OKabcdab"
  end

  it "pads with whitespace if no padstr is given" do
    "hello".ljust(20).should == "hello               "
  end

  it "returns self if it's longer than or as long as the specified length" do
    "".ljust(0).should == ""
    "".ljust(-1).should == ""
    "hello".ljust(4).should == "hello"
    "hello".ljust(-1).should == "hello"
    "this".ljust(3).should == "this"
    "radiology".ljust(8, '-').should == "radiology"
  end
end
