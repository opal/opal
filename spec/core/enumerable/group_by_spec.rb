describe "Enumerable#group_by" do
  it "returns a hash with values grouped according to the block" do
    grouped = [:foo, :bar, :baz].group_by { |word| word[0, 1].to_sym }
    grouped.should == { :f => [:foo], :b => [:bar, :baz] }
  end

  it "returns an empty hash for empty enumerables" do
    [].group_by { |x| x }.should == {}
  end

  it "allows nil as a valid key" do
    grouped = [[nil, :foo], [nil, :baz], [42, 100]].group_by { |arr| arr.first }
    grouped[nil].should == [[nil, :foo], [nil, :baz]]
    grouped[42].should == [[42, 100]]
  end
end
