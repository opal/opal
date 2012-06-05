describe "Time#month" do
  it "returns the month of the year for a UTC Time" do
    Time.new(1970, 1).month.should == 1
  end
end