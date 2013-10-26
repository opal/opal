describe "Enumerable#each_with_object" do
  it "breaks out with the proper value" do
    [1, 2, 3].each_with_object(23) { break 42 }.should == 42
  end
end
