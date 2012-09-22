describe "Kernel#equal?" do
  it "returns true only if obj and other are the same object" do
    o1 = Object.new
    o2 = Object.new
    o1.equal?(o1).should == true
    o2.equal?(o2).should == true
    o1.equal?(o2).should == false
    nil.equal?(nil).should == true
    o1.equal?(nil).should == false
    nil.equal?(o2).should == false
  end
end