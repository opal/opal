describe "Numeric#-@" do
  it "returns self as a negative value" do
    expect(2.send(:-@)).to eq(-2)
    expect(-2).to eq(-2)
    expect(-268435455).to eq(-268435455)
    expect(--5).to eq(5)
    expect((-8).send(:-@)).to eq(8)
  end
end