describe "Enumerable#take_while" do
  it "breaks out with the proper value" do
    expect([1, 2, 3].take_while { break 42 }).to eq(42)
  end
end
