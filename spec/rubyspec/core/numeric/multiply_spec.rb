describe "Numeric#*" do
  it "returns self multiplied by the given Integer" do
    (4923 * 2).should == 9846
    (1342177 * 800).should == 1073741600
    (65536 * 65536).should == 4294967296

    (6712 * 0.25).should == 1678.0
  end
end