describe "String#rindex" do
  it "should return index of last occurrence of search string" do
    "camal".rindex("a").should == 3
  end

  it "should return index of last occurrence of RegExp match" do
    "camal".rindex(/a/).should == 3
  end

  it "should return nil if non-empty search is not found" do
    "camal".rindex("x").should be_nil
  end

  it "should return nil if RegExp is not matched" do
    "camal".rindex(/x/).should be_nil
  end

  it "should return 0 if string and search string are both empty" do
    "".rindex("").should == 0
  end

  it "should return index of last occurrence of search string from offset" do
    "camal".rindex("a", 1).should == 1
    "camal".rindex(/a/, 4).should == 3
    "camal".rindex("a", -4).should == 1
    "camal".rindex("a", -2).should == 3
  end

  it "should return index of last occurrence of RegExp match from offset" do
    "camal".rindex(/a/, 1).should == 1
    "camal".rindex(/a/, 4).should == 3
    "camal".rindex(/a/, -4).should == 1
    "camal".rindex(/a/, -2).should == 3
  end

  it "should return nil of last occurrence is after offset" do
    "camal".rindex("a", 0).should be_nil
    "camal".rindex("a", -5).should be_nil
  end

  it "should return nil of last occurrence of RegExp match is after offset" do
    "camal".rindex(/a/, 0).should be_nil
    "camal".rindex(/a/, -5).should be_nil
  end

  it "should raise TypeError if search is not String or RegExp" do
    lambda { "camal".rindex(nil) }.should raise_error(TypeError)
    lambda { "camal".rindex(1) }.should raise_error(TypeError)
  end
end
