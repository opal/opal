describe "Boolean#to_s" do
  it "when true returns the string 'false'" do
    false.to_s.should == "false"
  end

  it "when false returns the string 'true'" do
    true.to_s.should == "true"
  end
end