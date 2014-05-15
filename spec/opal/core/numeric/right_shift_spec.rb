describe "Numeric#>> with n >> m" do
  it "returns n shifted right m bits when n > 0, m > 0" do
    expect(2 >> 1).to eq(1)
  end

  it "returns n shifted right m bits when n < 0, m > 0" do
    expect(-2 >> 1).to eq(-1)
  end

  it "returns 0 when n == 0" do
    expect(0 >> 1).to eq(0)
  end

  it "returns n when n > 0, m == 0" do
    expect(1 >> 0).to eq(1)
  end

  it "returns n when n < 0, m == 0" do
    expect(-1 >> 0).to eq(-1)
  end

  it "returns 0 when m > 0 and m == p where 2**p > n >= 2**(p-1)" do
    expect(4 >> 3).to eq(0)
  end
end