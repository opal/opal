describe "Element#tag" do
  it "should return the tag name of the receiver as a lower case string" do
    Element.new('div').tag.should == 'div'
    Element.new('script').tag.should == 'script'
    Element.new('ul').tag.should == 'ul'
  end
end