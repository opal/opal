require 'spec_helper'

describe "String" do
  it "handles contiguous parts correctly" do
    str = "a" "b"
    str.should == "ab"

    str2 = "d" "#{str}"
    str2.should == "dab"
  end
end
