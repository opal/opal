describe "Boolean#^" do
  it "when false returns false if other is nil or false, otherwise true" do
    (false ^ false).should == false
    (false ^ true).should == true
    (false ^ nil).should == false
    (false ^ "").should == true
    (false ^ mock('x')).should == true
  end

  it "when true returns true if other is nil or false, otherwise false" do
    (true ^ true).should == false
    (true ^ false).should == true
    (true ^ nil).should == true
    (true ^ "").should == false
    (true ^ mock('x')).should == false
  end
end