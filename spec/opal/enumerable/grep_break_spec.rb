describe "Enumerable#grep" do
  it "breaks out with the proper value" do
    [1, 2, 3].grep(1) { break 42 }.should == 42
  end
end
