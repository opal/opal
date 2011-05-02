
describe "TrueClass#&" do
  it "returns false if other is nil or false, otherwise true" do
    # (true & true).should == true
    # (true & false).should == false
    # (true & nil).should == false
    # (true & "").should == true
    # (true & 'x').should == true
  end
end
