describe "String#gsub with pattern and replacement" do
  it "returns a copy of self with all occurrences of pattern replaced with replacement" do
    "hello".gsub(/[aeiou]/, '*').should == "h*ll*"
  end

  it "ignores a block if supplied" do
    "food".gsub(/f/, "g") { "w" }.should == "good"
  end
end

describe "String#gsub with pattern and block" do
  it "returns a copy of self with all occurrences of pattern replaced with the block's return value" do
    "hello".gsub(/./) { |s| s.succ + ' ' }.should == "i f m m p "
    "hello!".gsub(/(.)(.)/) { |*a| a.inspect }.should == '["he"]["ll"]["o!"]'
    "hello".gsub('l') { 'x'}.should == 'hexxo'
  end

  it "should set the global match variable $~ inside block" do
    match_data = nil
    "hello".gsub(/(.)(.)(.)(.)(.)/) { match_data = $~; $~[1] }.should == "h"
    match_data.length.should == 6
    match_data.should == ["hello", "h", "e", "l", "l", "o"]
  end

  it "should replace match group with undefined value with nil in match array" do
    match_data = nil
    "def".gsub(/(a(b)c)?d(e)f/) { match_data = $~; $~[3] }.should == "e"
    match_data.length.should == 4
    match_data.should == ["def", nil, nil, "e"]
  end
end
