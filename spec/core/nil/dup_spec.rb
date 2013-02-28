require File.expand_path('../../../spec_helper', __FILE__)

describe "NilClass#dup" do
  it "raises a TypeError" do
    lambda { nil.dup }.should raise_error(TypeError)
  end
end
