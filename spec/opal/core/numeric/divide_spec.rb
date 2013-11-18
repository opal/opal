describe "Numeric#/" do
  it "returns self divided by the given argument" do
    (2 / 2).should == 1
    (3 / 2).should == 1.5
  end

  it "supports dividing negative numbers" do
    (-1 / 10).should == -0.1
  end
end