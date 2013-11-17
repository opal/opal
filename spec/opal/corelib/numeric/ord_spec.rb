describe "Numeric#ord" do
  it "returns self" do
    20.ord.should == 20
    40.ord.should == 40

    0.ord.should == 0
    (-10).ord.should == -10
  end
end