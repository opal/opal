require File.expand_path('../../spec_helper', __FILE__)

describe "The self keyword" do
  it "always returns s(:self)" do
    opal_parse("self").should == [:self]
  end

  it "cannot be assigned to" do
    lambda {
      opal_parse "self = 1"
    }.should raise_error(Exception)

    lambda {
      opal_parse "self = self"
    }.should raise_error(Exception)
  end
end
