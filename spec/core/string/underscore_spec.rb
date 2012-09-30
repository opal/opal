describe "String#underscore" do
  it "replaces '-' in dasherized strings with underscores" do
    "well-hello-there".underscore.should == "well_hello_there"
  end
  
  it "converts single all-upcase strings into lowercase" do
    "OMG".underscore.should == "omg"
  end
  
  it "splits word bounderies and seperates using underscore" do
    "AdamBeynon".underscore.should == "adam_beynon"
  end
  
  it "does not split when 2 or more capitalized letters together" do
    "HTMLParser".underscore.should == "html_parser"
  end
end