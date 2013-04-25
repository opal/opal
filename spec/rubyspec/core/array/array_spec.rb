require File.expand_path('../../../spec_helper', __FILE__)

describe "Array" do
  it "includes Enumerable" do
    Array.ancestors.include?(Enumerable).should == true
  end
end
