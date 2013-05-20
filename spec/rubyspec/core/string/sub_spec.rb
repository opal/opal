describe "String#sub with pattern, replacement" do
  it "returns a copy of self with all occurrences of pattern replaced with replacement" do
    "hello".sub(/[aeiou]/, '*').should == "h*llo"
    "hello".sub(//, ".").should == ".hello"
  end

  it "ignores a block if supplied" do
    "food".sub(/f/, "g") { "w" }.should == "good"
  end

  it "supports /i for ignoring case" do
    "Hello".sub(/h/i, "j").should == "jello"
    "hello".sub(/H/i, "j").should == "jello"
  end

  it "converts and supports back references in replacement string" do
    "javascript".sub(/(j).*(s).*/, '.\\1\\2').should == '.js'
  end
end

describe "String#sub with pattern and block" do
  it "returns a copy of self with the first occurences of pattern replaces with block's return value" do
    "hi".sub(/./) { |s| s + ' ' }.should == "h i"
    "hi!".sub(/(.)(.)/) { |*a| a.inspect }.should == '["hi"]!'
  end

  it "should set the global match variable $~ inside block" do
    match_datas = []
    "hello".sub(/(.)./) { match_datas << $~; $~[1].succ }.should == "illo"
    match_datas.length.should == 1
    match_datas[0].length.should == 2
    match_datas[0].should == ["he", "h"]
  end
end
