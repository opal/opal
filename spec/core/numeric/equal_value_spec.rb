describe "Numeric#==" do
  it "returns true if self has the same value as other" do
    (1 == 1).should == true
    (9 == 5).should == false

    (9 == 9.0).should == true
    (9 == 9.01).should == false
  end
end