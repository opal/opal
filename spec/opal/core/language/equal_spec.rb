describe "BasicObject#equal?" do
  it "compares usign low level identity" do
    obj = BasicObject.new
    obj2 = BasicObject.new
    obj.equal?(obj).should == true
    obj.equal?(obj2).should == false
  end
end
