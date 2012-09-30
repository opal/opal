describe "Numeric#>> with n >> m" do
  it "returns n shifted right m bits when n > 0, m > 0" do
    (2 >> 1).should == 1
  end

  it "returns n shifted right m bits when n < 0, m > 0" do
    (-2 >> 1).should == -1
  end

  it "returns 0 when n == 0" do
    (0 >> 1).should == 0
  end

  it "returns n when n > 0, m == 0" do
    (1 >> 0).should == 1
  end

  it "returns n when n < 0, m == 0" do
    (-1 >> 0).should == -1
  end

  it "returns 0 when m > 0 and m == p where 2**p > n >= 2**(p-1)" do
    (4 >> 3).should == 0
  end
end