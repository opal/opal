describe "Numeric#eql?" do
  it "returns true if self has the same value as other" do
    (1.eql? 1).should == true
    (9.eql? 5).should == false

    (9.eql? 9.0).should == true
    (9.eql? 9.01).should == false
  end
end