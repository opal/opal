describe "Numeric#**" do
  it "returns self raised to the given power" do
    (2 ** 0).should == 1
    (2 ** 1).should == 2
    (2 ** 2).should == 4

    (2 ** 40).should == 1099511627776
  end

  it "overflows the answer to a bignum transparantly" do
    (2 ** 29).should == 536870912
    (2 ** 30).should == 1073741824
    (2 ** 31).should == 2147483648
    (2 ** 32).should == 4294967296

    (2 ** 61).should == 2305843009213693952
    (2 ** 62).should == 4611686018427387904
    (2 ** 63).should == 9223372036854775808
    (2 ** 64).should == 18446744073709551616
  end

  it "raises negative numbers to the given power" do
    ((-2) ** 29).should == -536870912
    ((-2) ** 30).should == 1073741824
    ((-2) ** 31).should == -2147483648
    ((-2) ** 32).should == 4294967296

    ((-2) ** 61).should == -2305843009213693952
    ((-2) ** 62).should == 4611686018427387904
    ((-2) ** 63).should == -9223372036854775808
    ((-2) ** 64).should == 18446744073709551616
  end
end