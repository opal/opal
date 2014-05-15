describe "Numeric#**" do
  it "returns self raised to the given power" do
    expect(2 ** 0).to eq(1)
    expect(2 ** 1).to eq(2)
    expect(2 ** 2).to eq(4)

    expect(2 ** 40).to eq(1099511627776)
  end

  it "overflows the answer to a bignum transparantly" do
    expect(2 ** 29).to eq(536870912)
    expect(2 ** 30).to eq(1073741824)
    expect(2 ** 31).to eq(2147483648)
    expect(2 ** 32).to eq(4294967296)

    expect(2 ** 61).to eq(2305843009213693952)
    expect(2 ** 62).to eq(4611686018427387904)
    expect(2 ** 63).to eq(9223372036854775808)
    expect(2 ** 64).to eq(18446744073709551616)
  end

  it "raises negative numbers to the given power" do
    expect((-2) ** 29).to eq(-536870912)
    expect((-2) ** 30).to eq(1073741824)
    expect((-2) ** 31).to eq(-2147483648)
    expect((-2) ** 32).to eq(4294967296)

    expect((-2) ** 61).to eq(-2305843009213693952)
    expect((-2) ** 62).to eq(4611686018427387904)
    expect((-2) ** 63).to eq(-9223372036854775808)
    expect((-2) ** 64).to eq(18446744073709551616)
  end
end