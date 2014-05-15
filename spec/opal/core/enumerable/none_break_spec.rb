describe "Enumerable#none?" do
  it "breaks out with the proper value" do
    expect([1, 2, 3].none? { break 42 }).to eq(42)
  end
end
