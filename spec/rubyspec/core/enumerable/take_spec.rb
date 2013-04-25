require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../fixtures/classes', __FILE__)

describe "Enumerable#take" do
  before :each do
    @values = [4,3,2,1,0,-1]
    @enum = EnumerableSpecs::Numerous.new(*@values)
  end

  it "returns the take element" do
    EnumerableSpecs::Numerous.new.take.should == 2
    EnumerableSpecs::Empty.new.take.should == nil
  end

  it "returns nil if self is empty" do
    EnumerableSpecs::Empty.new.take.should == nil
  end

  it "returns the take count elements if given a count" do
    @enum.take(2).should == [4, 3]
    @enum.take(4).should == [4, 3, 2, 1]
  end

  it "returns an empty array when passed a count on an empty array" do
    empty = EnumerableSpecs::Empty.new
    empty.take(0).should == []
    empty.take(1).should == []
    empty.take(2).should == []
  end

  it "returns an empty array when passed count == 0" do
    @enum.take(0).should == []
  end

  it "returns an array containing the take element when passed count == 1" do
    @enum.take(1).should == [4]
  end

  it "returns the entire array when count > length" do
    @enum.take(100).should == @values
    @enum.take(8).should == @values
  end
end
