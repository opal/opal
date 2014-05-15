describe "Enumerable#each_with_object" do
  it "breaks out with the proper value" do
    expect([1, 2, 3].each_with_object(23) { break 42 }).to eq(42)
  end
end
