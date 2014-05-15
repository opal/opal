describe "Kernel#p" do
  before { extend OutputSilencer }

  it "returns nil if called with no arguments" do
    silence_stdout { expect(p).to eq(nil) }
  end

  it "returns its argument if called with one argument" do
    silence_stdout { expect(p(123)).to eq(123) }
  end

  it "returns all arguments as an Array if called with multiple arguments" do
    silence_stdout { expect(p(1,2,3)).to eq([1,2,3]) }
  end
end
