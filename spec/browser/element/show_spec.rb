describe "Element#show" do
  before do
    @div = Element.new

    @div.id   = 'show-spec'
    @div.html = <<-HTML
      <div id="show-spec-visible"></div>
      <div id="show-spec-hidden" style="display: none"></div>
    HTML

    @div.append_to_body
  end

  after do
    @div.remove
  end

  it "should show elements that are currently hidden" do
    elem = Element.find_by_id('show-spec-hidden')
    elem.visible?.should be_false
    elem.show
    elem.visible?.should be_true
  end

  it "should have no affect on elements already visible" do
    elem = Element.find_by_id('show-spec-visible')
    elem.visible?.should be_true
    elem.show
    elem.visible?.should be_true
  end
end