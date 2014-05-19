describe "Numeric#>=" do
  it "returns true if self is greater than or equal to the given argument" do
    expect(13 >= 2).to eq(true)
    expect(-500 >= -600).to eq(true)

    expect(1 >= 5).to eq(false)
    expect(2 >= 2).to eq(true)
    expect(5 >= 5).to eq(true)

    expect(5 >= 4.999).to eq(true)
  end
end