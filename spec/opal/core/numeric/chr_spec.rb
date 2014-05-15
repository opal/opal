describe "Numeric#chr" do
  it "returns a string containing the ASCII character represented by self" do
    expect(111.chr).to eq('o')
    expect(112.chr).to eq('p')
    expect(97.chr).to eq('a')
    expect(108.chr).to eq('l')
  end
end