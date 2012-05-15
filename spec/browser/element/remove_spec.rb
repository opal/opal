describe "Element#remove" do
  before do
    @div = Element.new

    @div.id   = 'remove_spec'
    @div.html = <<-HTML
      <div id="foo1">
        <div id="bar1"></div>
      </div>
      <div id="foo2">
        <div id="bar2"></div>
      </div>
    HTML

    @div.append_to_body
  end

  after do
    @div.remove
  end

  it "should return the element upon removal" do
    bar1 = Element.find_by_id 'bar1'
    bar1.remove.should == bar1
  end

  it "should completely remove the element from its parent" do
    Element.find_by_id('bar2').remove
    Element.find_by_id('foo2').empty?.should be_true
  end
end