describe "Enumerator#each" do
  it "yield each element of self to the given block" do
    acc = []
    enumerator_class.new([1, 2, 3]).each {|e| acc << e }
    acc.should == [1,2,3]
  end

  it "returns an enumerator if no block is given" do
    enumerator_class.new([1]).each.should be_kind_of(enumerator_class)
  end
end
