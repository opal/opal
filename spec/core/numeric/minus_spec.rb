describe "Numeric#-" do
  it "returns self minus the given Integer" do
    (5 - 10).should == -5
    (9237212 - 5_280).should == 9231932

    (781 - 0.5).should == 780.5
  end
end