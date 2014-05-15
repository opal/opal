describe "Numeric#ord" do
  it "returns self" do
    expect(20.ord).to eq(20)
    expect(40.ord).to eq(40)

    expect(0.ord).to eq(0)
    expect((-10).ord).to eq(-10)
  end
end