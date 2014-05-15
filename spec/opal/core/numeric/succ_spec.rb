describe "Numeric#succ" do
  it "returns the next larger positive Fixnum" do
    expect(2.succ).to eq(3)
  end

  it "returns the next larger negative Fixnum" do
    expect((-2).succ).to eq(-1)
  end
end