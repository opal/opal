describe "Opal::Parser" do
  it "should parse simple ruby values" do
    opal_eval('3.142').should == 3.142
    opal_eval('false').should == false
    opal_eval('true').should == true
    opal_eval('nil').should == nil
  end
end