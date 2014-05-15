describe "Enumerable#grep" do
  it "breaks out with the proper value" do
    expect([1, 2, 3].grep(1) { break 42 }).to eq(42)
  end
end
