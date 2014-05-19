describe "Numeric#zero?" do
  it "returns true if self is 0" do
    expect(0.zero?).to eq(true)
    expect((-1).zero?).to eq(false)
    expect(1.zero?).to eq(false)
  end
end