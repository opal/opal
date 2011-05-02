describe "Array#length" do
  it "returns the number of elements" do
    [].length.should == 0
    [1, 2, 3].length.should == 3
  end
end
