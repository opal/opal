describe "String#[]" do
  it "returns the character code of the character at the given index" do
    "hello"[0].should == "h"
    "hello"[-1].should == "o"
  end

  it "returns nil if index is outside of self" do
    "hello"[20].should == nil
    "hello"[-20].should == nil

    ""[0].should == nil
    ""[-1].should == nil
  end
end

describe "String#slice with index, length" do
  it "returns the substring starting at the given index with the given length" do
    "hello there"[0, 0].should == ""
    "hello there"[0, 1].should == "h"
    "hello there"[0, 3].should == "hel"
    "hello there"[0, 6].should == "hello "
    "hello there"[0, 9].should == "hello the"
    "hello there"[0, 12].should == "hello there"

    "hello there"[1, 0].should == ""
    "hello there"[1, 1].should == "e"
    "hello there"[1, 3].should == "ell"
    "hello there"[1, 6].should == "ello t"
    "hello there"[1, 9].should == "ello ther"
    "hello there"[1, 12].should == "ello there"

    "hello there"[3, 0].should == ""
    "hello there"[3, 1].should == "l"
    "hello there"[3, 3].should == "lo "
    "hello there"[3, 6].should == "lo the"
    "hello there"[3, 9].should == "lo there"

    "hello there"[4, 0].should == ""
    "hello there"[4, 3].should == "o t"
    "hello there"[4, 6].should == "o ther"
    "hello there"[4, 9].should == "o there"

    "foo"[2, 1].should == "o"
    "foo"[3, 0].should == ""
    "foo"[3, 1].should == ""

    ""[0, 0].should == ""
    ""[0, 1].should == ""

    "x"[0, 0].should == ""
    "x"[0, 1].should == "x"
    "x"[1, 0].should == ""
    "x"[-1, 1].should == "x"
  end

  it "returns nil if the offset falls outside of self" do
    "hello there"[20, 3].should == nil
    "hello there"[-20, 3].should == nil

    ""[1, 0].should == nil
    ""[1, 1].should == nil

    ""[2, 0].should == nil
    ""[2, 1].should == nil

    "x"[2, 0].should == nil
    "x"[2, 1].should == nil

    "x"[-2, 0].should == nil
    "x"[-2, 1].should == nil
  end
end