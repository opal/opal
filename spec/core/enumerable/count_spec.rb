require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../fixtures/classes', __FILE__)

describe "Enumerable#count" do
  before :each do
    @elements = [1, 2, 4, 2]
    @numerous = EnumerableSpecs::Numerous.new(*@elements)
  end

  it "returns size when no argument or a block" do
    @numerous.count.should == 4
  end

  it "counts nils if given nil as an argument" do
    EnumerableSpecs::Numerous.new(nil, nil, nil, false).count(nil).should == 3
  end

  it "accepts an argument for comparison using ==" do
    @numerous.count(2).should == 2
  end

  it "uses a block for comparison" do
    @numerous.count{|x| x%2==0 }.should == 3
  end

  it "ignores the block when given an argument" do
    @numerous.count(4){|x| x%2==0 }.should == 1
  end
end
