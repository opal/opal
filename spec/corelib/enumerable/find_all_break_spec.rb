describe "Enumerable#find_all" do
  it "breaks out with the proper value" do
    [1, 2, 3].find_all { break 42 }.should == 42
  end
end
