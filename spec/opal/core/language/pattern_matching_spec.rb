require 'spec_helper'

describe "pattern matching" do
  it "supports basic assignment" do
    5 => a
    a.should == 5
  end

  it "supports array pattern" do
    [1,2,3,4] => [1,2,*rest]
    rest.should == [3,4]
    [1,2,3,4] => [*rest,3,x]
    rest.should == [1,2]
    x.should == 4
  end

  it "supports hash pattern" do
    {a: 4} => {a:}
    a.should == 4
    {a: 4, b: 6} => {b:}
    b.should == 6
    {a: 1, b: 2, c: 3} => {a: 1, **rest}
    rest.should == {b: 2, c: 3}
  end

  it "supports pinning" do
    a = 6
    6 => ^a
    a.should == 6
  end

  it "supports a lambda literal" do
    [6, 7] => [->(a) { a == 6 }, b]
    b.should == 7
  end

  it "supports constants" do
    [6, 7, 8] => [Integer, a, Integer]
    a.should == 7
  end

  it "supports regexps" do
    "test" => /e(s)t/
    $1.should == 's'
  end

  it "supports save pattern" do
    [6, 7, 8] => [Integer=>a, Integer=>b, Integer=>c]
    [a,b,c].should == [6, 7, 8]
  end

  it "supports find pattern with save" do
    [1, 2, 3, 4, 5] => [*before, 3 => three, 4 => four, *after]
    before.should == [1,2]
    three.should == 3
    four.should == 4
    after.should == [5]
  end

  it "supports custom classes" do
    class TotallyArrayOrHashLike
      def deconstruct
        [1,2,3]
      end

      def deconstruct_keys(_)
        {a: 1, b: 2}
      end
    end

    TotallyArrayOrHashLike.new => TotallyArrayOrHashLike[*array]
    array.should == [1,2,3]

    TotallyArrayOrHashLike.new => TotallyArrayOrHashLike(**hash)
    hash.should == {a: 1, b: 2}
  end

  it "supports case expressions" do
    case 4
    in 4
      z = true
    in 5
      z = false
    end

    z.should == true
  end

  it "supports case expressions with guards" do
    case 4
    in 4 if false
      z = true
    in 4 if true
      z = false
    end

    z.should == false
  end

  it "raises if case expression is unmatched" do
    proc do
      case 4
      in 5
        :test
      end
    end.should raise_error NoMatchingPatternError
  end

  it "doesn't raise when else in a case expression is present" do
    case 4
    in 5
      z = true
    else
      z = false
    end

    z.should == false
  end

  it "doesn't raise or set variables if an in expression is unmatched" do
    4 in String => a
    a.should == nil
  end
end
