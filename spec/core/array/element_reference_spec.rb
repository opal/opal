require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../fixtures/classes', __FILE__)

describe "Array#[]" do
  it "returns the element at index with [index]" do
    [ "a", "b", "c", "d", "e" ][1].should == "b"

    a = [1, 2, 3, 4]
    a[0].should == 1
    a[1].should == 2
    a[2].should == 3
    a[3].should == 4
    a[4].should == nil
    a[10].should == nil

    a.should == [1, 2, 3, 4]
  end

  it "returns the element at index from the end of the array with [-index]" do
    [ "a", "b", "c", "d", "e" ][-2].should == "d"

    a = [1, 2, 3, 4]
    a[-1].should == 4
    a[-2].should == 3
    a[-3].should == 2
    a[-4].should == 1
    a[-5].should == nil
    a[-10].should == nil

    a.should == [1, 2, 3, 4]
  end

  it "returns count elements starting from index with [index, count]" do
    [ "a", "b", "c", "d", "e" ][2, 3].should == ["c", "d", "e"]

    a = [1, 2, 3, 4]

    a[0, 0].should == []
    a[0, 1].should == [1]
    a[0, 2].should == [1, 2]
    a[0, 4].should == [1, 2, 3, 4]
    a[0, 6].should == [1, 2, 3, 4]
    a[0, -1].should == nil
    a[0, -2].should == nil
    a[0, -4].should == nil

    a[2, 0].should == []
    a[2, 1].should == [3]
    a[2, 2].should == [3, 4]
    a[2, 4].should == [3, 4]
    a[2, -1].should == nil

    a[4, 0].should == []
    a[4, 2].should == []
    a[4, -1].should == nil

    a[5, 0].should == nil
    a[5, 2].should == nil
    a[5, -1].should == nil

    a[6, 0].should == nil
    a[6, 2].should == nil
    a[6, -1].should == nil

    a.should == [1, 2, 3, 4]
  end

  it "returns count elements starting at index from the end of array with [-index, count]" do
    [ "a", "b", "c", "d", "e" ][-2, 2].should == ["d", "e"]

    a = [1, 2, 3, 4]
    a[-1, 0].should == []
    a[-1, 1].should == [4]
    a[-1, 2].should == [4]
    a[-1, -1].should == nil

    a[-2, 0].should == []
    a[-2, 1].should == [3]
    a[-2, 2].should == [3, 4]
    a[-2, 4].should == [3, 4]
    a[-2, -1].should == nil

    a[-4, 0].should == []
    a[-4, 1].should == [1]
    a[-4, 2].should == [1, 2]
    a[-4, 4].should == [1, 2, 3, 4]
    a[-4, 6].should == [1, 2, 3, 4]
    a[-4, -1].should == nil

    a[-5, 0].should == nil
    a[-5, 1].should == nil
    a[-5, 10].should == nil
    a[-5, -1].should == nil

    a.should == [1, 2, 3, 4]
  end

  it "returns the first count elements with [0, count]" do
    [ "a", "b", "c", "d", "e" ][0, 3].should == ["a", "b", "c"]
  end

  it "returns the subarray which is independent to self with [index,count]" do
    a = [1, 2, 3]
    sub = a[1,2]
    sub.replace([:a, :b])
    a.should == [1, 2, 3]
  end

  it "returns the elements specified by Range indexes with [m..n]" do
    [ "a", "b", "c", "d", "e" ][1..3].should == ["b", "c", "d"]
    [ "a", "b", "c", "d", "e" ][4..-1].should == ['e']
    [ "a", "b", "c", "d", "e" ][3..3].should == ['d']
    [ "a", "b", "c", "d", "e" ][3..-2].should == ['d']
    ['a'][0..-1].should == ['a']


    a = [1, 2, 3, 4]

    a[0..-10].should == []
    a[0..0].should == [1]
    a[0..1].should == [1, 2]
    a[0..2].should == [1, 2, 3]
    a[0..3].should == [1, 2, 3, 4]
    a[0..4].should == [1, 2, 3, 4]
    a[0..10].should == [1, 2, 3, 4]

    a[2..-10].should == []
    a[2..0].should == []
    a[2..2].should == [3]
    a[2..3].should == [3, 4]
    a[2..4].should == [3, 4]

    a[3..0].should == []
    a[3..3].should == [4]
    a[3..4].should == [4]

    a[4..0].should == []
    a[4..4].should == []
    a[4..5].should == []

    a[5..0].should == nil
    a[5..5].should == nil
    a[5..6].should == nil

    a.should == [1, 2, 3, 4]
  end

  it "returns elements specified by Range indexes except the lement at index n with [m...n]" do
    [ "a", "b", "c", "d", "e" ][1...3].should == ["b", "c"]

    a = [1, 2, 3, 4]

    a[0...-10].should == []
    a[0...0].should == []
    a[0...1].should == [1]
    a[0...2].should == [1, 2]
    a[0...3].should == [1, 2, 3]
    a[0...4].should == [1, 2, 3, 4]
    a[0...10].should == [1, 2, 3, 4]

    a[2...-10].should == []
    a[2...0].should == []
    a[2...2].should == []
    a[2...3].should == [3]
    a[2...4].should == [3, 4]

    a[3...0].should == []
    a[3...3].should == []
    a[3...4].should == [4]

    a[4...0].should == []
    a[4...4].should == []
    a[4...5].should == []

    a[5...0].should == nil
    a[5...5].should == nil
    a[5...6].should == nil

    a.should == [1, 2, 3, 4]
  end

  it "returns nil for a requested index not in the array with [index]" do
    [ "a", "b", "c", "d", "e" ][5].should == nil
  end

  it "returns [] of the index is valid but length is zero with [index, length]" do
    [ "a", "b", "c", "d", "e" ][0, 0].should == []
    [ "a", "b", "c", "d", "e" ][2, 0].should == []
  end

  it "returns nil if length is zero but index is invalid with [index, length]" do
    [ "a", "b", "c", "d", "e" ][100, 0].should == nil
    [ "a", "b", "c", "d", "e" ][-50, 0].should == nil
  end

  it "returns [] if index == array.size with [index, length]" do
    %w|a b c d e|[5, 2].should == []
  end

  it "returns nil if index > array.size with [index, length]" do
    %w|a b c d e|[6, 2].should == nil
  end

  it "returns nil if length is negative with [index, length]" do
    %w|a b c d e|[3, -1].should == nil
    %w|a b c d e|[2, -2].should == nil
    %w|a b c d e|[1, -100].should == nil
  end
end
