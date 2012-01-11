require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../fixtures/classes', __FILE__)

describe "Array#each_index" do
  before :each do
    ScratchPad.record []
  end

  it "passes the index of each element to the block" do
    a = ['a', 'b', 'c', 'd']
    a.each_index { |i| ScratchPad << i }
    ScratchPad.recorded.should == [0, 1, 2, 3]
  end

  it "returns self" do
    a = [:a, :b, :c]
    a.each_index { |i| }.should equal(a)
  end

  it "is not confused by removing elements from the front" do
    a = [1, 2, 3]

    a.shift
    ScratchPad.record []
    a.each_index { |i| ScratchPad << i }
    ScratchPad.recorded.should == [0, 1]

    a.shift
    ScratchPad.record []
    a.each_index { |i| ScratchPad << i }
    ScratchPad.recorded.should == [0]
  end
end
