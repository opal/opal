describe "Numeric#modulo" do
  it "returns the modulus obtained from dividing self by the given argument" do
    expect(13.modulo(4)).to eq(1)
    expect(4.modulo(13)).to eq(4)

    expect(13.modulo(4.0)).to eq(1)
    expect(4.modulo(13.0)).to eq(4)
  end
end

describe "Numeric#%" do
  it "returns the modulus obtained from dividing self by the given argument" do
    expect(13 % 4).to eq(1)
    expect(4 % 13).to eq(4)

    expect(13 % 4.0).to eq(1)
    expect(4 % 13.0).to eq(4)
  end
end