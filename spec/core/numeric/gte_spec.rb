describe "Numeric#>=" do
  it "returns true if self is greater than or equal to the given argument" do
    (13 >= 2).should == true
    (-500 >= -600).should == true

    (1 >= 5).should == false
    (2 >= 2).should == true
    (5 >= 5).should == true

    (5 >= 4.999).should == true
  end
end