describe "Enumerable#any?" do
  it "breaks out with the proper value" do
    [1, 2, 3].any? { break 42 }.should == 42
  end
end
