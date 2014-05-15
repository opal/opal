describe "Numeric#*" do
  it "returns self multiplied by the given Integer" do
    expect(4923 * 2).to eq(9846)
    expect(1342177 * 800).to eq(1073741600)
    expect(65536 * 65536).to eq(4294967296)

    expect(6712 * 0.25).to eq(1678.0)
  end
end