describe :enumerable_take, :shared => true do
  before :each do
    @values = [4,3,2,1,0,-1]
    @enum = EnumerableSpecs::Numerous.new(*@values)
  end

  it "returns the first count elements if given a count" do
    @enum.first(2).should == [4, 3]
    @enum.first(4).should == [4, 3, 2, 1]
  end

  it "returns an empty array when passed count on an empty array" do
    empty = EnumerableSpecs::Empty.new
    empty.first(0).should == []
    empty.first(1).should == []
    empty.first(2).should == []
  end

  it "returns an empty array when passed count == 0" do
    @enum.first(0).should == []
  end

  it "returns an array containing the first element when passed count == 1" do
    @enum.first(1).should == [4]
  end

  it "returns the entire array when count > length" do
    @enum.first(100).should == @values
    @enum.first(8).should == @values
  end
end
