describe "Hash#flatten" do
  before(:each) do
    @h = {:plato => :greek,
          :witgenstein => [:austrian, :british],
          :russell => :welsh}
  end

  it "returns an Array" do
    {}.flatten.should be_kind_of(Array)
  end

  it "returns an empty Array for an empty Hash" do
    {}.flatten.should == []
  end

  it "sets each even index of the Array to a key of the hash" do
    a = @h.flatten
    a[0].should == :plato
    a[2].should == :witgenstein
    a[4].should == :russell
  end

  it "sets each odd index of the Array to the value corresponding to the previous element" do
    a = @h.flatten
    a[1].should == :greek
    a[3].should == [:austrian, :british]
    a[5].should == :welsh
  end

  it "does not recursively flatten Array values when called without arguments" do
    a = @h.flatten
    a[3].should == [:austrian, :british]
  end

  it "does not recursivley flatten Hash values when called without arguments" do
    @h[:russell] = {:born => :wales, :influenced_by => :mill}
    a = @h.flatten
    a[5].should_not == {:born => :wales, :influenced_by => :mill}.flatten
  end

  it "recursively flattens Array values when called with an argument >= 2" do
    a = @h.flatten(2)
    a[3].should == :austrian
    a[4].should == :british
  end
end