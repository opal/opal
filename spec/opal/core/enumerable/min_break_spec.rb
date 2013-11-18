describe "Enumerable#min" do
  it "breaks out with the proper value" do
    [1, 2, 3].min { break 42 }.should == 42
  end
end
