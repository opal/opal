require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../fixtures/classes', __FILE__)

describe "Enumerable#collect" do
  before :each do
    ScratchPad.record []
  end

  it "returns a new array with the results of passing each element to block" do
    entries = [0, 1, 3, 4, 5, 6]
    numerous = EnumerableSpecs::Numerous.new(*entries)
    numerous.collect { |i| i % 2 }.should == [0, 1, 1, 0, 1, 0]
    numerous.collect { |i| i }.should == entries
  end
end
