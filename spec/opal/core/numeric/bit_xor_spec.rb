describe "Numeric#^" do
  it "returns self bitwise EXCLUSIVE OR other" do
    expect(3 ^ 5).to eq(6)
    expect(-2 ^ -255).to eq(255)
  end
end