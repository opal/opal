describe "String#demodulize" do
  it "removes any preceding module name from the string" do
    "Foo::Bar".demodulize.should == "Bar"
    "Foo::Bar::Baz".demodulize.should == "Baz"
  end
  
  it "has no affect on strings with no module seperator" do
    "SomeClassName".demodulize.should == "SomeClassName"
  end
end