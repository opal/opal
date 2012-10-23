describe "Kernel#p" do
  it "returns nil if called with no arguments" do
    p.should == nil
  end
  
  it "returns its argument if called with one argument" do
    p(123).should == 123
  end
  
  it "returns all arguments as an Array if called with multiple arguments" do
    p(1,2,3).should == [1,2,3]
  end
end