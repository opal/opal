describe "Numeric#next" do
  it "returns the next larger positive Fixnum" do
    expect(2.next).to eq(3)
  end

  it "returns the next larger negative Fixnum" do
    expect((-2).next).to eq(-1)
  end
end