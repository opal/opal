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