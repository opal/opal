describe "Numeric#/" do
  it "returns self divided by the given argument" do
    expect(2 / 2).to eq(1)
    expect(3 / 2).to eq(1.5)
  end

  it "supports dividing negative numbers" do
    expect(-1 / 10).to eq(-0.1)
  end
end