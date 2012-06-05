describe "Time#now" do
  it "should return the current time" do
    Time.now.should be_kind_of(Time)
  end
end