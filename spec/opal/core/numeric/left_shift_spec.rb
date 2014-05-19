describe "Numeric#<< with n << m" do
  it "returns n shifted left m bits when n > 0, m > 0" do
    expect(1 << 1).to eq(2)
  end

  it "returns n shifted left m bits when n < 0, m > 0" do
    expect(-1 << 1).to eq(-2)
  end

  it "returns 0 when n == 0" do
    expect(0 << 1).to eq(0)
  end

  it "returns n when n > 0, m == 0" do
    expect(1 << 0).to eq(1)
  end

  it "returns n when n < 0, m == 0" do
    expect(-1 << 0).to eq(-1)
  end
end