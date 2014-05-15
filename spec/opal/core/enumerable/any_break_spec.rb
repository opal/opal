describe "Enumerable#any?" do
  it "breaks out with the proper value" do
    expect([1, 2, 3].any? { break 42 }).to eq(42)
  end
end
