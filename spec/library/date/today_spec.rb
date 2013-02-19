require "spec_helper"

describe "Date.today" do
  it "creates a new instance for current date" do
    Date.today.should be_kind_of(Date)
  end
end
