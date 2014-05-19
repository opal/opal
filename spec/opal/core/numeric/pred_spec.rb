describe "Numeric#pred" do
  it "returns the Integer equal to self - 1" do
    expect(0.pred).to eq(-1)
    expect((-1).pred).to eq(-2)
    expect(20.pred).to eq(19)
  end
end