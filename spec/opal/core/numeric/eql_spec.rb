describe "Numeric#eql?" do
  it "returns true if self has the same value as other" do
    expect(1.eql? 1).to eq(true)
    expect(9.eql? 5).to eq(false)

    expect(9.eql? 9.0).to eq(true)
    expect(9.eql? 9.01).to eq(false)
  end
end