describe "Numeric#-" do
  it "returns self minus the given Integer" do
    expect(5 - 10).to eq(-5)
    expect(9237212 - 5_280).to eq(9231932)

    expect(781 - 0.5).to eq(780.5)
  end
end