describe "Element#initialize" do
  it "should create a new native div element when given no args" do
    Element.new.tag.should == 'div'
  end

  it "should create a new native element when given a tag name" do
    Element.new('div').tag.should == 'div'
    Element.new('h1').tag.should == 'h1'
  end

  it "should just wrap a native element passed to constructor" do
    first  = `document.createElement('div')`
    second = `document.body`

    Element.new(first).tag.should == 'div'
    Element.new(second).tag.should == 'body'
  end

  it "returns an error when a non element is passed" do
    lambda do
      Element.new(`{}`)
    end.should raise_error(Exception)
  end
end