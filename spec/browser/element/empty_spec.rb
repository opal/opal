describe "Element#empty?" do
  before do
    @div = Element.new

    @div.id   = 'empty_spec'
    @div.html = <<-HTML
      <div id="foo"></div>
      <div id="bar"></div>
      <div id="baz">
        <span></span>
      </div>
      <div id="biz">Hello</div>
    HTML

    @div.append_to_body
  end

  after do
    @div.remove
  end

  it "returns true if the element has no children, false otherwise" do
    Element.find_by_id('foo').empty?.should be_true
    Element.find_by_id('baz').empty?.should be_false
    Element.find_by_id('biz').empty?.should be_false
  end

  it "returns true if there is just whitespace in the element" do
    Element.find_by_id('bar').empty?.should be_true
  end
end