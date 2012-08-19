describe "Time#day" do
  it "returns the day of the month for a UTC Time" do
    Time.new(1970, 1, 1).day.should == 1
  end
end