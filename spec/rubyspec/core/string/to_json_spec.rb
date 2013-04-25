describe "String#to_json" do
  it "returns an escaped string" do
    "foo".to_json.should == "\"foo\""
    "bar\nbaz".to_json.should == "\"bar\\nbaz\""
  end
end