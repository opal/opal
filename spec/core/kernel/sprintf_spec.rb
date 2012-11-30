describe "Kernel#sprintf" do
  it "returns formatted string as same as Kernel#format" do
    sprintf("%5d", 123).should == "  123"
  end
end
