describe "FalseClass#&" do
  it "returns false" do
    (false & true).should == false
    (false & false).should == false
    (false & nil).should == false
    (false & "").should == false
    (false & mock('x')).should == false
  end
end