describe "Hash#indices" do
  it "returns an array of values for the given keys" do
    h = {:a => 9, :b => 'a', :c => -10, :d => nil}
    h.indices.should be_kind_of(Array)
    h.indices.should == []
    h.indices(:a, :d, :b).should be_kind_of(Array)
    h.indices(:a, :d, :b).should == [9, nil, 'a']
  end
end