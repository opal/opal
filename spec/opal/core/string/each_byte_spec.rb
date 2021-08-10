require 'spec_helper'

describe "String#each_byte" do
  it "get bytes from UTF-8 character (2 bytes)" do
    a = []
    "ʆ".each_byte { |c| a << c }
    a.should == [202, 134]
  end
  it "get bytes from UTF-8 character (3 bytes)" do
    a = []
    "ቜ".each_byte { |c| a << c }
    a.should == [225, 137, 156]
  end
  it "get bytes from UTF-8 emoji (4 bytes)" do
    a = []
    "👋".each_byte { |c| a << c }
    a.should == [240, 159, 145, 139]
  end
end
