require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../fixtures/classes', __FILE__)

describe "Array#uniq" do
  it "returns an array with no duplicates" do
    ["a", "a", "b", "b", "c"].uniq.should == ["a", "b", "c"]
  end

  it "uses eql? semantics" do
    [1.0, 1].should == [1.0, 1]
  end
end

describe "Hash#uniq!" do
  it "modifies the array in place" do
    a = [ "a", "a", "b", "b", "c" ]
    a.uniq!
    a.should == ["a", "b", "c"]
  end

  it "returns self" do
    a = [ "a", "a", "b", "b", "c" ]
    a.should equal(a.uniq!)
  end
end
