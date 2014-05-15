describe "Kernel.rand" do
  it "returns a float if no argument is passed" do
    expect(rand).to be_kind_of(Float)
  end

  it "returns an integer for an integer argument" do
    expect(rand(77)).to be_kind_of(Integer)
  end

  it "return member from range" do
    r = (1..10)
    expect(r.to_a.include?(rand(r))).to eq(true)
  end

  it "should convert negative number and convert to integer" do
    expect(rand(-0.1)).to eq(0)
  end

  it "returns a numeric in opal" do
    expect(rand).to be_kind_of(Numeric)
    expect(rand(77)).to be_kind_of(Numeric)
  end
end
