describe "Enumerable#find_index" do
  it "breaks out with the proper value" do
    expect([1, 2, 3].find_index { break 42 }).to eq(42)
  end
end
