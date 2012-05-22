describe "Hash#keys" do
  it "returns an array with the keys in the order they were inserted" do
    {}.keys.should == []
    {}.keys.should be_kind_of(Array)
    Hash.new(5).keys.should == []
    Hash.new { 5 }.keys.should == []
    # {1 => 2, 2 => 8, 4 => 4}.keys.should == [1, 4, 2]
    {nil => nil}.keys.should == [nil]
  end
end