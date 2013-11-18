describe "Numeric#<=" do
  it "returns true if self is less than or equal to other" do
    (2 <= 13).should == true
    (-600 <= -500).should == true

    (5 <= 1).should == false
    (5 <= 5).should == true
    (-2 <= -2).should == true

    (5 <= 4.999).should == false
  end
end