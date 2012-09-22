describe "Array#inspect" do
  it "returns a String" do
    [1, 2, 3].inspect.should be_kind_of(String)
  end

  it "returns '[]' for an empty Array" do
    [].inspect.should == "[]"
  end

  it "calls inspect on its elements and joins the results with commas" do
    [0, 1, 2].inspect.should == "[0, 1, 2]"
  end
end