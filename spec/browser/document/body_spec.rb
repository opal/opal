describe "Document.body" do
  it "returns the body element as an Element instance" do
    Document.body.tag.should == 'body'
  end
end