require File.expand_path('../../spec_helper', __FILE__)

describe "$1..$9" do
  it "parses as s(:nth_ref)" do
    opal_parse('$1').first.should == :nth_ref
  end

  it "references the number 1..9 as first part" do
    opal_parse('$1').should == [:nth_ref, '1']
    opal_parse('$9').should == [:nth_ref, '9']
  end
end

