require File.expand_path('../../../spec_helper', __FILE__)
require 'strscan'

describe "StringScanner#pos=" do
  before :each do
    @s = StringScanner.new("This is a test")
    @m = StringScanner.new("colourful")
  end

  it "modify the scan pointer" do
    @s.pos = 5
    @s.rest.should == "is a test"
  end

  it "positions from the end if the argument is negative" do
    @s.pos = -2
    @s.rest.should == "st"
    @s.pos.should == 12
  end
end
