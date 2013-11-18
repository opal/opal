describe "Numeric#floor" do
  it "returns the floor'ed value" do
    1.floor.should == 1
    (-42).floor.should == -42
    3.142.floor.should == 3
    0.floor.should == 0
  end
end