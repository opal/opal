require File.expand_path('../../spec_helper', __FILE__)

describe "The nil keyword" do
  it "always returns s(:nil)" do
    opal_parse("nil").should == [:nil]
  end

  it "cannot be assigned to" do
    lambda {
      opal_parse "nil = 1"
    }.should raise_error(Exception)

    lambda {
      opal_parse "nil = nil"
    }.should raise_error(Exception)
  end
end
