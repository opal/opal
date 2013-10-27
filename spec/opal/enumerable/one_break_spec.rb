describe "Enumerable#one?" do
  it "breaks out with the proper value" do
    [1, 2, 3].one? { break 42 }.should == 42
  end
end
