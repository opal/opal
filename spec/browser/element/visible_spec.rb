describe "Element#visible?" do
  before do
    @div = Element.new

    @div.id   = 'visible-spec'
    @div.html = <<-HTML
      <div id="visible-spec-first" style="display: none"></div>
      <div id="visible-spec-second"></div>
    HTML

    @div.append_to_body
  end

  after do
    @div.remove
  end

  it "should return true when the element is visible, false otherwise" do
    Element.find_by_id('visible-spec-second').visible?.should be_true
    Element.find_by_id('visible-spec-first').visible?.should be_false
  end
end