describe "Numeric#ceil" do
  it "returns the ceil'ed value" do
    expect(1.ceil).to eq(1)
    expect((-42).ceil).to eq(-42)
    expect(3.142.ceil).to eq(4)
    expect(0.ceil).to eq(0)
  end
end