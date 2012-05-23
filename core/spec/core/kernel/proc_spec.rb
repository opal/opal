describe "Kernel#proc" do
  it "returns a Proc object" do
    proc { true }.kind_of?(Proc).should == true
  end

  it "raises an ArgumentError when no block is given" do
    lambda { proc }.should raise_error(ArgumentError)
  end
end