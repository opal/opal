require File.expand_path('../../spec_helper', __FILE__)

describe "The unless keyword" do
  it "returns s(:if) with reversed true and false bodies" do
    opal_parse("unless 10; 20; end").should == [:if, [:lit, 10], nil, [:lit, 20]]
    opal_parse("unless 10; 20; 30; end").should == [:if, [:lit, 10], nil, [:block, [:lit, 20], [:lit, 30]]]
    opal_parse("unless 10; 20; else; 30; end").should == [:if, [:lit, 10], [:lit, 30], [:lit, 20]]
  end

  it "returns s(:if) with reversed true and false bodies for prefix unless" do
    opal_parse("20 unless 10").should == [:if, [:lit, 10], nil, [:lit, 20]]
  end
end
