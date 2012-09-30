describe "Numeric#<< with n << m" do
  it "returns n shifted left m bits when n > 0, m > 0" do
    (1 << 1).should == 2
  end

  it "returns n shifted left m bits when n < 0, m > 0" do
    (-1 << 1).should == -2
  end

  it "returns 0 when n == 0" do
    (0 << 1).should == 0
  end

  it "returns n when n > 0, m == 0" do
    (1 << 0).should == 1
  end

  it "returns n when n < 0, m == 0" do
    (-1 << 0).should == -1
  end
end