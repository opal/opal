describe "Time#hour" do
  it "returns the hour of the day for a UTC time" do
    Time.new(1970, 1, 1, 0).hour.should == 0
  end
end