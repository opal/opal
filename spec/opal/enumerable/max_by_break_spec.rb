describe "Enumerable#max_by" do
  it "breaks out with the proper value" do
    [1, 2, 3].max_by { break 42 }.should == 42
  end
end
