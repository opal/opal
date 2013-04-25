require "spec_helper"

describe "Date.new" do
  it "creates a date with arguments" do
    d = Date.new(2000, 3, 5)
    d.year.should == 2000
    d.month.should == 3
    d.day.should == 5
  end
end
