describe "String#slice" do
  it "returns the character code of the character at the given index" do
    "hello".slice(0).should == "h"
    "hello".slice(-1).should == "o"
  end

  it "returns nil if index is outside of self" do
    "hello".slice(20).should == nil
    "hello".slice(-20).should == nil

    "".slice(0).should == nil
    "".slice(-1).should == nil
  end
end

describe "String#slice with index, length" do
  it "returns the substring starting at the given index with the given length" do
    "hello there".slice(0, 0).should == ""
    "hello there".slice(0, 1).should == "h"
    "hello there".slice(0, 3).should == "hel"
    "hello there".slice(0, 6).should == "hello "
    "hello there".slice(0, 9).should == "hello the"
    "hello there".slice(0, 12).should == "hello there"

    "hello there".slice(1, 0).should == ""
    "hello there".slice(1, 1).should == "e"
    "hello there".slice(1, 3).should == "ell"
    "hello there".slice(1, 6).should == "ello t"
    "hello there".slice(1, 9).should == "ello ther"
    "hello there".slice(1, 12).should == "ello there"

    "hello there".slice(3, 0).should == ""
    "hello there".slice(3, 1).should == "l"
    "hello there".slice(3, 3).should == "lo "
    "hello there".slice(3, 6).should == "lo the"
    "hello there".slice(3, 9).should == "lo there"

    "hello there".slice(4, 0).should == ""
    "hello there".slice(4, 3).should == "o t"
    "hello there".slice(4, 6).should == "o ther"
    "hello there".slice(4, 9).should == "o there"

    "foo".slice(2, 1).should == "o"
    "foo".slice(3, 0).should == ""
    "foo".slice(3, 1).should == ""

    "".slice(0, 0).should == ""
    "".slice(0, 1).should == ""

    "x".slice(0, 0).should == ""
    "x".slice(0, 1).should == "x"
    "x".slice(1, 0).should == ""
    "x".slice(-1, 1).should == ""
  end

  it "returns nil if the offset falls outside of self" do
    "hello there".slice(20, 3).should == nil
    "hello there".slice(-20, 3).should == nil

    "".slice(1, 0).should == nil
    "".slice(1, 1).should == nil

    "".slice(2, 0).should == nil
    "".slice(2, 1).should == nil

    "x".slice(2, 0).should == nil
    "x".slice(2, 1).should == nil

    "x".slice(-2, 0).should == nil
    "x".slice(-2, 1).should == nil
  end
end