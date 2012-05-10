describe "Array#size" do
  it "returns the number of elements" do
    [].size.should == 0
    [1, 2, 3].size.should == 3
  end
end