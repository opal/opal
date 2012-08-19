describe "Kernel.rand" do
  it "returns a float if no argument is passed" do
    # rand.should be_kind_of(Float)
  end

  it "returns an integer for an integer argument" do
    # rand(77).should be_kind_of(Integer)
  end

  it "returns a numeric in opal" do
    rand.should be_kind_of(Numeric)
    rand(77).should be_kind_of(Numeric)
  end
end