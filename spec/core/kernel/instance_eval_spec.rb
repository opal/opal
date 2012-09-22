describe "Kernel#instance_eval" do
  before :each do
    ScratchPad.clear
  end

  it "yields the object to the block" do
    "hola".instance_eval { |o| ScratchPad.record o }
    ScratchPad.recorded.should == "hola"
  end

  it "returns the result of the block" do
    "hola".instance_eval { :result }.should == :result
  end

  it "binds self to the receiver" do
    s = "hola"
    (s == s.instance_eval { self }).should be_true
  end

  it "executes in the context of the receiver" do
    "Ruby-fu".instance_eval { size }.should == 7
  end

  it "has access to receiver's instance variables" do
    @foo_bar = 42
    instance_eval { @foo_bar }.should == 42
  end
end