describe "Element#clear" do
  it "removes all child nodes and returns self" do
    e = Element.find_by_id('foo')
    # e.clear.should == e
  end
end