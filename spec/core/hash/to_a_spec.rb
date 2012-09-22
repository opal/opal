describe "Hash#to_a" do
  it "returns a list of [key, value] pairs with same order as each()" do
    h = {:a => 1, 1 => :a, 3 => :b, :b => 5}
    pairs = []

    h.each_pair do |key, value|
      pairs << [key, value]
    end

    h.to_a.should be_kind_of(Array)
    h.to_a.should == pairs
  end
end