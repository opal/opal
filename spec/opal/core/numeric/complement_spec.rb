describe "Numeric#~" do
  it "returns self with each bit flipped" do
    expect(~0).to eq(-1)
    expect(~1221).to eq(-1222)
    expect(~-2).to eq(1)
    expect(~-599).to eq(598)
  end
end