describe "Enumerable#each_with_index" do
  it "breaks out with the proper value" do
    expect([1, 2, 3].each_with_index { break 42 }).to eq(42)
  end
end
