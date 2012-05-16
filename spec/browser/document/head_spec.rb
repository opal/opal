describe "Document.head" do
  it "returns the head element as an Element instance" do
    Document.head.tag.should == 'head'
  end
end