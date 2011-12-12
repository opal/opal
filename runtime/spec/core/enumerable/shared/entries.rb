describe :enumerable_entries, :shared => true do
  it "returns an array containing the elements" do
    numerous = EnumerableSpecs::Numerous.new(1, nil, 'a', 2, false, true)
    numerous.to_a.should == [1, nil, "a", 2, false, true]
  end
end
