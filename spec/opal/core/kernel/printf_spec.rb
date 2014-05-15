describe "Kernel#printf" do
  before { extend OutputSilencer }

  it "returns nil if called with no arguments" do
    silence_stdout { expect(printf).to eq(nil) }
  end

  it "returns nil if called with arguments" do
    silence_stdout { expect(printf("%d", 123)).to eq(nil) }
  end
end
