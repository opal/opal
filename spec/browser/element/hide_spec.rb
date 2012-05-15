describe "Element#hide" do
  before do
    @div = Element.new

    @div.id   = 'hide-spec'
    @div.html = <<-HTML
      <div id="hide-spec-visible"></div>
      <div id="hide-spec-hidden" style="display: none"></div>
    HTML

    @div.append_to_body
  end

  after do
    @div.remove
  end

  it "should hide elements that are currently visible" do
    elem = Element.find_by_id('hide-spec-visible')
    elem.visible?.should be_true
    elem.hide
    elem.visible?.should be_false
  end

  it "should leave hidden elements hidden" do
    elem = Element.find_by_id('hide-spec-hidden')
    elem.visible?.should be_false
    elem.hide
    elem.visible?.should be_false
  end
end