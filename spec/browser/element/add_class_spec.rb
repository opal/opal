describe "Element#add_class" do
  before do
    @div = Element.new

    @div.id   = 'add-class-spec'
    @div.html = <<-HTML
      <div id="foo" class="apples"></div>
      <div id="bar"></div>
      <div id="baz" class="lemons bananas"></div>
      <div id="buz" class="mangos"></div>
    HTML

    @div.append_to_body
  end

  after do
    @div.remove
  end

  it "should add the given class_name onto the element" do
    foo = Element.id 'foo'
    foo.add_class 'oranges'
    foo.class_name.should == 'apples oranges'

    bar = Element.id 'bar'
    bar.add_class 'pineapples'
    bar.class_name.should == 'pineapples'
  end

  it "should not add the class if the element already has given class" do
    baz = Element.id 'baz'
    baz.add_class 'lemons'
    baz.class_name.should == 'lemons bananas'

    baz.add_class 'bananas'
    baz.class_name.should == 'lemons bananas'

    baz.add_class 'grapes'
    baz.class_name.should == 'lemons bananas grapes'

    buz = Element.id 'buz'
    buz.add_class 'mangos'
    buz.class_name.should == 'mangos'

    buz.add_class 'melons'
    buz.class_name.should == 'mangos melons'
  end

  it "returns self" do
    spec = Element.id('add-class-spec')
    spec.add_class('wow').should == spec
  end
end