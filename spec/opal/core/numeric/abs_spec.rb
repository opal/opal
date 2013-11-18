describe "Numeric#abs" do
  it "returns self's absolute value" do
    (-100).abs.should == 100
    (100).abs.should == 100

    (-0).abs.should == 0
    (0).abs.should == 0

    (-42).abs.should == 42
    (42).abs.should == 42
  end
end