describe "Numeric#upto [stop] when self and stop are Fixnums" do
  it "does not yield when stop is less than self" do
    result = []
    5.upto(4) { |x| result << x }
    expect(result).to eq([])
  end

  it "yields once when stop equals self" do
    result = []
    5.upto(5) { |x| result << x }
    expect(result).to eq([5])
  end

  it "yields while increasing self until it is less than stop" do
    result = []
    2.upto(5) { |x| result << x }
    expect(result).to eq([2, 3, 4, 5])
  end
end