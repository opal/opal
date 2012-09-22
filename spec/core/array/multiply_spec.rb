describe "Array#* with an integer" do
  it "concatenates n copies of the array when passed an integer" do
    ([1, 2, 3] * 0).should == []
    ([1, 2, 3] * 1).should == [1, 2, 3]
    ([1, 2, 3] * 3).should == [1, 2, 3, 1, 2, 3, 1, 2, 3]
  end
end

describe "Array#* with a string" do
  it "returns a string formed by concatenating each element with separator" do
    ([1, 2, 3, 4, 5] * ' | ').should == "1 | 2 | 3 | 4 | 5"
  end
end