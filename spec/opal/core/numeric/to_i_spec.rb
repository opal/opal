describe "Numeric#to_i" do
  it "returns self as an integer" do
    10.to_i.should == 10
    (-15).to_i.should == -15
    3.142.to_i.should == 3
  end
end