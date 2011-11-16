require File.expand_path('../../../spec_helper', __FILE__)

describe "Array#count" do
  it "returns the count of elements" do
    [1, :two, 'three'].count.should == 3
  end

  it "returns count of elements that equals given object" do
    [1, 'some text', 'other text', 2, 1].count(1).should == 2
  end
end
