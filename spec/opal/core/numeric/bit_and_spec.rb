describe "Numeric#&" do
  it "returns self bitwise AND other" do
    expect(256 & 16).to eq(0)
    expect(2010 & 5).to eq(0)
    expect(65535 & 1).to eq(1)
  end
end