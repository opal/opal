describe "Enumerable#drop_while" do
  before :each do
    @enum = EnumerableSpecs::Numerous.new(3, 2, 1, :go)
  end

  it "returns an Enumerator if no block given" do
    @enum.drop_while.should be_kind_of(Enumerator)
  end

  it "returns no/all elements for {true/false} block" do
    @enum.drop_while {true}.should == []
    @enum.drop_while {false}.should == @enum.to_a
  end

  it "accepts returns other than true/false" do
    @enum.drop_while{1}.should == []
    @enum.drop_while{nil}.should == @enum.to_a
  end

  it "passed elements to the block until the first false" do
    a = []
    @enum.drop_while{|obj| (a << obj).size < 3}.should == [1, :go]
  end
end