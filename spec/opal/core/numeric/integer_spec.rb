describe "Numeric#integer?" do
  it "returns true if number is integer, false otherwise" do
    expect(0.integer?).to eq(true)
    expect((-1).integer?).to eq(true)
    expect(1.integer?).to eq(true)

    expect(3.142.integer?).to eq(false)
  end
end