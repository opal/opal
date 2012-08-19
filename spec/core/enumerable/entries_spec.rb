describe "Enumerable#entries" do
  it "returns an array containing the elements" do
    numerous = EnumerableSpecs::Numerous.new(1, nil, 'a', 2, false, true)
    numerous.entries.should == [1, nil, "a", 2, false, true]
  end
end