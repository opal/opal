describe "Numeric#ceil" do
  it "returns the ceil'ed value" do
    1.ceil.should == 1
    (-42).ceil.should == -42
    3.142.ceil.should == 4
    0.ceil.should == 0
  end
end