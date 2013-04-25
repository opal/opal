describe "Numeric#integer?" do
  it "returns true if number is integer, false otherwise" do
    0.integer?.should == true
    (-1).integer?.should == true
    1.integer?.should == true

    3.142.integer?.should == false
  end
end