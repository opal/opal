describe "Kernel#instance_eval" do
  before :each do
    ScratchPad.clear
  end

  it "yields the object to the block" do
    "hola".instance_eval { |o| ScratchPad.record o }
    expect(ScratchPad.recorded).to eq("hola")
  end

  it "returns the result of the block" do
    expect("hola".instance_eval { :result }).to eq(:result)
  end

  it "binds self to the receiver" do
    s = "hola"
    expect(s == s.instance_eval { self }).to be_true
  end

  it "executes in the context of the receiver" do
    expect("Ruby-fu".instance_eval { size }).to eq(7)
  end

  it "has access to receiver's instance variables" do
    @foo_bar = 42
    expect(instance_eval { @foo_bar }).to eq(42)
  end
end