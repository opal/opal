require File.expand_path('../../../spec_helper', __FILE__)
require 'strscan'

describe "StringScanner#[]" do
  before :each do
    @s = StringScanner.new("Fri Jun 13 2008 22:43")
  end

  it "returns nil if there is no current match" do
    @s[0].should be_nil
  end

  it "returns the n-th subgroup in the most recent match" do
    @s.scan(/(\w+) (\w+) (\d+) /)
    @s[0].should == "Fri Jun 13 "
    @s[1].should == "Fri"
    @s[2].should == "Jun"
    @s[3].should == "13"
    @s[-3].should == "Fri"
    @s[-2].should == "Jun"
    @s[-1].should == "13"
  end

  it "returns nil if index is outside of self" do
    @s.scan(/(\w+) (\w+) (\d+) /)
    @s[5].should == nil
    @s[-5].should == nil
  end
end
