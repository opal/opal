describe "Element.find" do
  before do
    @div = Element.new

    @div.id   = 'find-spec'
    @div.html = <<-HTML
      <div class="find-foo"></div>
      <div class="find-bar"></div>
      <div class="find-foo"></div>
    HTML

    @div.append_to_body
  end

  after do
    @div.remove
  end

  it "should search and find elements matching CSS selector" do
    foo = Element.find '.find-foo'
    foo.should be_kind_of(Array)
    foo.length.should == 2

    bar = Element.find '.find-bar'
    bar.length.should == 1
    bar.first.tag.should == 'div'
  end
end

describe "Element#find" do
  before do
    @div = Element.new

    @div.id   = '-find-spec'
    @div.html = <<-HTML
      <div id="foo">
        <span class="a"></span>
        <span class="b"></span>
      </div>
      <div id="bar">
        <span class="b"></span>
        <span class="b"></span>
        <span class="c"></span>
      </div>
    HTML

    @div.append_to_body
  end

  after do
    @div.remove
  end

  it "should find elements matching selector only within element scope" do
    foo = Element.id 'foo'
    bar = Element.id 'bar'

    foo.find('.a').size.should == 1
    foo.find('.b').size.should == 1
    foo.find('.c').size.should == 0

    bar.find('.a').size.should == 0
    bar.find('.b').size.should == 2
    bar.find('.c').size.should == 1
  end
end