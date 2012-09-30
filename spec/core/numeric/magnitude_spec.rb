describe "Numeric#magnitude" do
  it "returns self's absolute value" do
    (-100).magnitude.should == 100
    (100).magnitude.should == 100

    (-0).magnitude.should == 0
    (0).magnitude.should == 0

    (-42).magnitude.should == 42
    (42).magnitude.should == 42
  end
end