describe "Numeric#|" do
  it "returns self bitwise OR other" do
    expect(1 | 0).to eq(1)
    expect(5 | 4).to eq(5)
    expect(5 | 6).to eq(7)
    expect(248 | 4096).to eq(4344)
  end
end