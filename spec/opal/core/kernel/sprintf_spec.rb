describe "Kernel#sprintf" do
  it "returns formatted string as same as Kernel#format" do
    expect(sprintf("%5d", 123)).to eq("  123")
  end
end
