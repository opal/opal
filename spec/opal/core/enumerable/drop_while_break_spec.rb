describe "Enumerable#drop_while" do
  it "breaks out with the proper value" do
    expect([1, 2, 3].drop_while { break 42 }).to eq(42)
  end
end
