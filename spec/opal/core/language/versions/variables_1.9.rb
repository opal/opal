describe "Multiple assignments with splats" do
  it "* on the LHS has to be applied to any parameter" do
    a, *b, c = 1, 2, 3
    expect(a).to eq(1)
    expect(b).to eq([2])
    expect(c).to eq(3)
  end
end
