describe "Kernel#methods" do
  it "lists methods available on an object" do
    Object.new.methods.include?("puts").should == true
  end
  
  it "lists only singleton methods if false is passed" do
    o = Object.new
    def o.foo; 123; end
    o.methods(false).should == ["foo"]
  end
end