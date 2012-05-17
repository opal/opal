describe "Element#class_name" do
  before do
    @div = Element.new

    @div.id   = 'class-name-spec'
    @div.html = <<-HTML
      <div id="foo" class="whiskey"></div>
      <div id="bar" class="scotch brandy"></div>
      <div id="baz" class=""></div>
      <div id="buz" class=""></div>
    HTML

    @div.append_to_body
  end

  after do
    @div.remove
  end

  it "should return the elements class name" do
    Element.id('foo').class_name.should == "whiskey"
    Element.id('bar').class_name.should == "scotch brandy"
  end

  it "should return an empty string for classes with no class name" do
    Element.id('baz').class_name.should == ""
    Element.id('buz').class_name.should == ""
  end
end

describe "Element#class_name=" do
  before do
    @div = Element.new

    @div.id   = 'class-name-spec-2'
    @div.html = <<-HTML
      <div id="foo" class=""></div>
      <div id="bar" class="oranges"></div>
    HTML

    @div.append_to_body
  end

  after do
    @div.remove
  end

  it "should set the given class name on the element" do
    Element.id('foo').class_name = "apples"
    Element.id('foo').class_name.should == "apples"
  end

  it "should replace any existing class name" do
    bar = Element.id 'bar'
    bar.class_name.should == "oranges"

    bar.class_name = "lemons"
    bar.class_name.should == "lemons"
  end
end