describe "Enumerable#take_while" do
  it "breaks out with the proper value" do
    [1, 2, 3].take_while { break 42 }.should == 42
  end
end
