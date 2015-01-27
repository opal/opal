require 'spec_helper'

describe "begin & rescue blocks" do
  it "should evaluate to begin blocks last expression when no exception" do
    result = begin
      "a"
    rescue
      "b"
    end

    result.should == "a"
  end

  it "should evaluate to rescue blocks last expression when exception" do
    result = begin
      raise "foo"
    rescue
      "bar"
    end

    result.should == "bar"
  end
end
