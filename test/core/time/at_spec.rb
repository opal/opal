describe "Time#at" do
  describe "passed Numeric" do
    it "returns a Time object representing the given number of Integer seconds since 1970-01-01 00:00:00 UTC" do
      Time.at(1184027924).should be_kind_of(Time)
    end
  end
end