describe "Kernel#class" do
  it "returns the class of the receiver" do
    Object.new.class.should == Object
    [].class.should == Array
  end
end