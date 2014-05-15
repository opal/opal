describe "Numeric#+" do
  it "returns self plus the given Integer" do
    expect(491 + 2).to eq(493)
    expect(90210 + 10).to eq(90220)

    expect(1001 + 5.219).to eq(1006.219)
  end
end