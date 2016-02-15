describe "Enumerator#with_index" do
  it "returns the result of the previously called method" do
    [1, 2, 3].each.with_index { |item, index| item * 2 }.should == [1, 2, 3]
    [1, 2, 3].map.with_index  { |item, index| item * 2 }.should == [2, 4, 6]
  end
end
