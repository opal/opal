describe "Numeric#pred" do
  it "returns the Integer equal to self - 1" do
    0.pred.should == -1
    (-1).pred.should == -2
    20.pred.should == 19
  end
end