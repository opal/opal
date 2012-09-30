describe "Numeric#to_s when no base given" do
  it "returns self converted to a String using base 10" do
    255.to_s.should == '255'
    3.to_s.should == '3'
    0.to_s.should == '0'
    (-9002).to_s.should == '-9002'
  end
end