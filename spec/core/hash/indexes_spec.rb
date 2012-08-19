describe "Hash#indexes" do
  it "returns an array of values for the given keys" do
    h = {:a => 9, :b => 'a', :c => -10, :d => nil}
    h.indexes.should be_kind_of(Array)
    h.indexes.should == []
    h.indexes(:a, :d, :b).should be_kind_of(Array)
    h.indexes(:a, :d, :b).should == [9, nil, 'a']
  end
end