describe "Numeric#floor" do
  it "returns the floor'ed value" do
    expect(1.floor).to eq(1)
    expect((-42).floor).to eq(-42)
    expect(3.142.floor).to eq(3)
    expect(0.floor).to eq(0)
  end
end