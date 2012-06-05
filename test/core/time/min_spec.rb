describe "Time#min" do
  it "returns the minute of the hour for a UTC Time" do
    Time.new(1970, 1, 1, 0, 0).min.should == 0
  end
end