describe "Array#select" do
  it "returns a new array of elements for which block is true" do
    [1, 3, 4, 5, 6, 9].select { |i| i.odd? }.should == [1, 3, 5, 9]
    [1, 2, 3, 4, 5, 6].select { true }.should == [1, 2, 3, 4, 5, 6]
    [1, 2, 3, 4, 5, 6].select { false }.should == []
  end
end

describe "Array#select!" do
  it "returns nil if no changes were made in the array" do
    [1, 2, 3].select! { true }.should be_nil
  end
end