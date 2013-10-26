describe "Enumerable#drop_while" do
  it "breaks out with the proper value" do
    [1, 2, 3].drop_while { break 42 }.should == 42
  end
end
