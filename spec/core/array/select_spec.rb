require File.expand_path('../../../spec_helper', __FILE__)

describe "Array#select" do
  it "returns a new array of elements for which block is true" do
    [1, 3, 4, 5, 6, 9].select { |i| i % ((i + 1) / 2) == 0 }.should == [1, 2, 3]
  end
end
