describe "Numeric#+" do
  it "returns self plus the given Integer" do
    (491 + 2).should == 493
    (90210 + 10).should == 90220

    (1001 + 5.219).should == 1006.219
  end
end