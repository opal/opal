describe "Numeric#<=>" do
  it "returns -1 when self is less than the given argument" do
    expect(-3 <=> -1).to eq(-1)
    expect(-5 <=> 10).to eq(-1)
    expect(-5 <=> -4.5).to eq(-1)
  end

  it "returns 0 when self is equal to the given argument" do
    expect(0 <=> 0).to eq(0)
    expect(954 <=> 954).to eq(0)
    expect(954 <=> 954.0).to eq(0)
  end

  it "returns 1 when self is greater than the given argument" do
    expect(496 <=> 5).to eq(1)
    expect(200 <=> 100).to eq(1)
    expect(51 <=> 50.5).to eq(1)
  end

  it "returns nil when the given argument is not an Numeric" do
    expect(3 <=> double('x')).to eq(nil)
    expect(3 <=> 'test').to eq(nil)
  end
end