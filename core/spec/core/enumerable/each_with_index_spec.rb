describe "Enumerable#each_with_index" do
  before :each do
    @b = EnumerableSpecs::Numerous.new(2, 5, 3, 6, 1, 4)
  end

  it "passes each element and its index to block" do
    @a = []
    @b.each_with_index { |o, i| @a << [o, i] }
    @a.should == [[2, 0], [5, 1], [3, 2], [6, 3], [1, 4], [4, 5]]
  end
end