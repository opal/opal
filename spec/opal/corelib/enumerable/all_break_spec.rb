describe "Enumerable#all?" do
  it "breaks out with the proper value" do
    [1, 2, 3].all? { break 42 }.should == 42
  end
end
