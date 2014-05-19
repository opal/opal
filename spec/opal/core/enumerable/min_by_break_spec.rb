describe "Enumerable#min_by" do
  it "breaks out with the proper value" do
    expect([1, 2, 3].min_by { break 42 }).to eq(42)
  end
end
