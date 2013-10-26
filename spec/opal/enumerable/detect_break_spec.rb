describe "Enumerable#detect" do
  it "breaks out with the proper value" do
    [1, 2, 3].detect { break 42 }.should == 42
  end
end
