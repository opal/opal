describe "Array#keep_if" do
  it "deletes elements for which the block returns a false value" do
    array = [1, 2, 3, 4, 5]
    array.keep_if { |item| item > 3 }.should equal(array)
    array.should == [4, 5]
  end
end