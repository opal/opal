describe "Boolean#&" do
  it "when false returns false" do
    (false & true).should == false
    (false & false).should == false
    (false & nil).should == false
    (false & "").should == false
    (false & mock('x')).should == false
  end

  it "when true returns false if other is nil or false, otherwise true" do
    (true & true).should == true
    (true & false).should == false
    (true & nil).should == false
    (true & "").should == true
    (true & mock('x')).should == true
  end
end