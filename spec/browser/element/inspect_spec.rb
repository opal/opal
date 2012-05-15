describe "Element#inspect" do
  it "should return a string representation of the element" do
    str = Element.new.inspect
    str.should == "<div>"
  end
end