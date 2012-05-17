describe "Element#remove_class" do
  before do
    @div = Element.new

    @div.id   = 'remove-class-spec'
    @div.html = <<-HTML
      <div id="foo" class="apples oranges"></div>
      <div id="bar" class="grapes limes mangos"></div>
      <div id="baz" class="melons lemons"></div>
      <div id="buz" class="pineapples"></div>
      <div id="biz"></div>
      <div id="boz" class="da di do"></div>
    HTML

    @div.append_to_body
  end

  after do
    @div.remove
  end

  it "should remove the given class name from the element" do
    foo = Element.id 'foo'
    foo.remove_class 'apples'
    foo.class_name.should == 'oranges'

    bar = Element.id 'bar'
    bar.remove_class 'limes'
    bar.class_name.should == 'grapes mangos'

    baz = Element.id 'baz'
    baz.remove_class 'lemons'
    baz.class_name.should == 'melons'

    buz = Element.id 'buz'
    buz.remove_class 'pineapples'
    buz.class_name.should == ''
  end

  it "should have no affect on elements not containing class name" do
    biz = Element.id 'biz'
    biz.remove_class 'woosh'
    biz.class_name.should == ''

    boz = Element.id 'boz'
    boz.remove_class 'kapow'
    boz.class_name.should == 'da di do'
  end

  it "returns self" do
    spec = Element.id 'remove-class-spec'
    spec.remove_class('omg').should == spec
  end
end