describe "Array#join" do
  it "returns a string formed by concatenating each element with separator" do
    [1, 2, 3, 4, 5].join(' | ').should == "1 | 2 | 3 | 4 | 5"
  end

  it "does not separate elements when the passed separator is nil" do
    [1, 2, 3].join(nil).should == '123'
  end
end