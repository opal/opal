describe "Numeric#>" do
  it "returns true if self is greater than the given argument" do
    (13 > 2).should == true
    (-500 > -600).should == true

    (1 > 5).should == false
    (5 > 5).should == false

    (5 > 4.999).should == true
  end
end