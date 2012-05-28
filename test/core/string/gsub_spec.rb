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
end