describe "Numeric#succ" do
  it "returns the next larger positive Fixnum" do
    2.succ.should == 3
  end

  it "returns the next larger negative Fixnum" do
    (-2).succ.should == -1
  end
end