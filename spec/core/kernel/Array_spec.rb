describe "Kernel#Array" do
  it "returns an Array containing the argument if it responds to neither #to_ary nor #to_a" do
    obj = mock('obj')
    Array(obj).should == [obj]
  end

  it "returns an empty Array when passed nil" do
    Array(nil).should == []
  end
end