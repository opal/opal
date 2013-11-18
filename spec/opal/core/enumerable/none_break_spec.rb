describe "Enumerable#none?" do
  it "breaks out with the proper value" do
    [1, 2, 3].none? { break 42 }.should == 42
  end
end
