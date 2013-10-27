describe "Enumerable#find_index" do
  it "breaks out with the proper value" do
    [1, 2, 3].find_index { break 42 }.should == 42
  end
end
