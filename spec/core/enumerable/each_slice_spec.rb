require "spec_helper"

describe "Enumerable#each_slice" do
  before :each do
    @enum = EnumerableSpecs::Numerous.new(7,6,5,4,3,2,1)
    @sliced = [[7,6,5],[4,3,2],[1]]
  end

  it "passes element groups to the block" do
    acc = []
    @enum.each_slice(3) { |g| acc << g }.should be_nil
    acc.should == @sliced
  end

  it "works when n is >= full length" do
    full = @enum.to_a
    acc = []
    @enum.each_slice(full.length) { |g| acc << g }
    acc.should == [full]
    acc = []
    @enum.each_slice(full.length + 1) { |g| acc << g }
    acc.should == [full]
  end
end
