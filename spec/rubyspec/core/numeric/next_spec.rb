describe "Numeric#next" do
  it "returns the next larger positive Fixnum" do
    2.next.should == 3
  end

  it "returns the next larger negative Fixnum" do
    (-2).next.should == -1
  end
end