require File.expand_path('../../spec_helper', __FILE__)
require File.expand_path('../fixtures/array', __FILE__)

describe "Array literals" do
  it "[] should return a new array populated with the given elements" do
    array = [1, 'a', nil]
    array.class.should == Array
    array[0].should == 1
    array[1].should == "a"
    array[2].should == nil
  end

  it "[] treats empty expressions as nil elements" do
    array = [0, (), 2, (), 4]
    array.class.should == Array
    array[0].should == 0
    array[1].should == nil
    array[2].should == 2
    array[3].should == nil
    array[4].should == 4
  end

  it "[] accepts a literal hash without curly braces as its only parameter" do
    ["foo" => :bar, :baz => 42].should == [{ "foo" => :bar, :baz => 42 }]
  end
end

describe "Bareword array literal" do
  it "%w() transforms unquoted barewords into an array" do
    a = 3
    %w(a #{3+a} 3).should == ['a', '#{3+a}', '3']
  end

  it "%W() transforms unquoted barewords into an array, supporing interpolation" do
    a = 3
    %W(a #{3+a} 3).should == ["a", "6", "3"]
  end
  
  it "%W() always treats interpolated expressions as a single word" do
    a = "hello world"
    %W(a b c #{a} d e).should == ["a", "b", "c", "hello world", "d", "e"]
  end
  
  it "treats consecutive whitespace characters the same as one" do
    %W(a  b c  d).should == ["a", "b", "c", "d"]
    %W(hello
       world).should == ["hello", "world"]
  end
  
  it "treats whitespace as literals characters when escaped by a backslash" do
    %W(a b\ c d e).should == ["a", "b c", "d", "e"]
  end
  
end

describe "The unpacking splat operator (*)" do
  it "when applied to a literal nested array, unpacks its elements into the containing array" do
    [1, 2, *[3, 4, 5]].should == [1, 2, 3, 4, 5]
  end
  
  it "when applied to a nested referenced array, unpacks its elements into the containing array" do
    splatted_array = [3, 4, 5]
    [1, 2, *splatted_array].should == [1, 2, 3, 4, 5]
  end
  
  it "when applied to a value with no other items in the containing array, coerces the passed value to an array and returns it unchanged" do
    splatted_array = [3, 4, 5]
    [*splatted_array].should == splatted_array
  end
end
