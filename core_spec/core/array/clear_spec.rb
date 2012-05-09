describe "Array#clear" do
  it "removes all elements" do
    a = [1, 2, 3, 4]
    a.clear
    a.should == []
  end

  it "returns self" do
    a = [1]
    old = a.object_id
    a.clear.object_id.should == old
  end

  it "leaves the Array empty" do
    a = [1]
    a.clear
    a.empty?.should == true
    a.size.should == 0
  end
end