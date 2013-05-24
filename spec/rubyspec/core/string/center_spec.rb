describe "String#center" do

  it "does nothing if the specified width is lower than the string's size" do
    "abc".center(2).should == "abc"
  end

  it "center a string with a strange pattern" do
    "ab".center(17, '12345').should == "1234512ab12345123"
  end

  describe "centers an odd string with a odd number of padding strings" do
    it "uses default padding" do
      "abc".center(5).should == " abc "
    end

    it "uses a custum padding" do
      "abc".center(5, '-').should == "-abc-"
    end

    it "works with bigger patterns" do
      "abc".center(7, '~!{').should == "~!abc~!"
    end

    it "repeats the pattern if needed" do
      "abc".center(10, '~!{').should == "~!{abc~!{~"
    end
  end

  describe "centers an even string with an odd number of padding strings" do
    it "uses default padding" do
      "abcd".center(7).should == " abcd  "
    end

    it "works with bigger patterns" do
      "abcd".center(7, '~!{').should == "~abcd~!"
    end

    it "repeats the pattern if needed" do
      "abcd".center(11, '~!{').should == "~!{abcd~!{~"
    end
  end

  describe "centers an even string with an even number of padding strings" do
    it "uses default padding" do
      "abcd".center(8).should == "  abcd  "
    end

    it "works with bigger patterns" do
      "abcd".center(8, '~!{').should == "~!abcd~!"
    end

    it "repeats the pattern if needed" do
      "abcd".center(12, '~!{').should == "~!{~abcd~!{~"
    end
  end

  describe "center an odd string with an even number" do
    it "uses default padding" do
      "abc".center(4).should == "abc "
    end

    it "works with bigger patterns" do
      "abc".center(4, '~!{').should == "abc~"
    end

    it "repeats the pattern if needed" do
      "abc".center(12, '~!{').should == "~!{~abc~!{~!"
    end
  end

end
