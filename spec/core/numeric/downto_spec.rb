describe "Numeric#downto [stop] when self and stop are Fixnums" do
  it "does not yield when stop is greater than self" do
    result = []
    5.downto(6) { |x| result << x }
    result.should == []
  end

  it "yields once when stop equals self" do
    result = []
    5.downto(5) { |x| result << x }
    result.should == [5]
  end

  it "yields while decreasing self until it is less than stop" do
    result = []
    5.downto(2) { |x| result << x }
    result.should == [5, 4, 3, 2]
  end
end