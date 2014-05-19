describe "Numeric#to_f" do
  it "returns self converted to a Float" do
    expect(0.to_f).to eq(0.0)
    expect((-500).to_f).to eq(-500.0)
    expect(9_641_278.to_f).to eq(9641278.0)
  end
end