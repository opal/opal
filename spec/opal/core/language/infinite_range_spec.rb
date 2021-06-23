describe "Infinite ranges" do
  it "supports endless ranges" do
    range = (10..)
    range.begin.should == 10
    range.end.should == nil
  end

  it "supports beginless ranges" do
    range = (..10)
    range.begin.should == nil
    range.end.should == 10
  end
end
