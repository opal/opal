require "spec_helper"

describe "Date#to_s" do
  it "returns a string representation of date (YYYY-MM-DD)" do
    Date.new(2012, 10, 26).to_s.should == "2012-10-26"
  end
end
