describe "Boolean#inspect" do
  it "when false returns the string 'false'" do
    false.inspect.should == "false"
  end

  it "when true returns the string 'true'" do
    true.inspect.should == "true"
  end
end