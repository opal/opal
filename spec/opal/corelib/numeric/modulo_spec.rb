describe "Numeric#modulo" do
  it "returns the modulus obtained from dividing self by the given argument" do
    13.modulo(4).should == 1
    4.modulo(13).should == 4

    13.modulo(4.0).should == 1
    4.modulo(13.0).should == 4
  end
end

describe "Numeric#%" do
  it "returns the modulus obtained from dividing self by the given argument" do
    (13 % 4).should == 1
    (4 % 13).should == 4

    (13 % 4.0).should == 1
    (4 % 13.0).should == 4
  end
end