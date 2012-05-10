describe "Hash#assoc" do
  before(:each) do
    @h = {:apple => :green, :orange => :orange, :grape => :green, :banana => :yellow}
  end

  it "returns an Array is the argument is == to a key of the Hash" do
    @h.assoc(:apple).should be_kind_of(Array)
  end

  it "returns a 2-element Array if the argument is == to a key of the Hash" do
    @h.assoc(:grape).size.should == 2
  end

  it "sets the first element of the Array to the located key" do
    @h.assoc(:banana).first.should == :banana
  end

  it "sets the last element of the Array to the value of the located key" do
    @h.assoc(:banana).last.should == :yellow
  end

  it "returns nil if the argument if not a key of the Hash" do
    @h.assoc(:green).should be_nil
  end
end