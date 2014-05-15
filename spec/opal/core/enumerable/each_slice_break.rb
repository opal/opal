describe "Enumerable#each_slice" do
  it "breaks out with the proper value" do
    expect([1, 2, 3].each_slice(1) { break 42 }).to eq(42)
    expect([1, 2, 3].each_slice(2) { break 42 }).to eq(42)
  end
end
