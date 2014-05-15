describe "Numeric#to_i" do
  it "returns self as an integer" do
    expect(10.to_i).to eq(10)
    expect((-15).to_i).to eq(-15)
    expect(3.142.to_i).to eq(3)
  end
end