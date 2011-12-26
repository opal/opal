require File.expand_path('../../../spec_helper', __FILE__)

describe "Regexps with interpolation" do

  it "allows interpolation of strings" do
    str = "foo|bar"
    /#{str}/.should == /foo|bar/
  end
end
