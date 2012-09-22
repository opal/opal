describe "Hash#delete" do
  it "removes the entry and returns the deleted value" do
    h = {a: 5, b: 2}
    h.delete(:b).should == 2
    h.should == {a: 5}
  end

  it "returns nil if the key is not found" do
    {}.delete(:a).should == nil
  end
end