require 'cli/spec_helper'

describe "Multiline comments" do
  it "parses multiline comments and ignores them" do
    parsed("=begin\nfoo\n=end\n100").should == [:int, 100]
  end

  it "raises an exception if not closed before end of file" do
    lambda { parsed("=begin\nfoo\nbar") }.should raise_error(Exception, /embedded document meets end of file/)
  end
end
