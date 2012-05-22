describe "Hash#values_at" do
  it "returns an array of values for the given keys" do
    h = {:a => 9, :b => 'a', :c => -10, :d => nil}
    h.values_at.should be_kind_of(Array)
    h.values_at.should == []
    h.values_at(:a, :d, :b).should be_kind_of(Array)
    h.values_at(:a, :d, :b).should == [9, nil, 'a']
  end
end