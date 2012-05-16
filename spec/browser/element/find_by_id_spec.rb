describe "Element.id" do
  before do
    @div = Element.new

    @div.id   = 'find_by_id_spec'
    @div.html = <<-HTML
      <div id="foo"></div>
      <div id="bar"></div>
    HTML

    @div.append_to_body
  end

  after do
    @div.remove
  end

  it "should return nil when no elements with the given id exist" do
    Element.id('bad_element_id').should be_nil
  end

  it "should return an Element instance when a matching element is found" do
    Element.id('foo').should be_kind_of(Element)
  end
end