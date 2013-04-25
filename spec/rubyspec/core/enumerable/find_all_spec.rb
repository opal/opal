require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../fixtures/classes', __FILE__)

describe "Enumerable#find_all" do
  before :each do
    ScratchPad.record []
    @elements = [1, 2, 3, 4, 5, 6, 7, 8, 9]
    @numerous = EnumerableSpecs::Numerous.new(*@elements)
  end

  it "returns all elements for which the block is not false" do
    @numerous.find_all {|i| i % 3 == 0 }.should == [3, 6, 9]
    @numerous.find_all {|i| true }.should == @elements
    @numerous.find_all {|i| false }.should == []
  end
end
