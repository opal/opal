describe "Boolean#|" do
  it "when false returns false if other is nil or false, otherwise true" do
    (false | false).should == false
    (false | true).should == true
    (false | nil).should == false
    (false | "").should == true
    (false | mock('x')).should == true
  end

  it "when true returns true" do
    (true | true).should == true
    (true | false).should == true
    (true | nil).should == true
    (true | "").should == true
    (true | mock('x')).should == true
  end
end