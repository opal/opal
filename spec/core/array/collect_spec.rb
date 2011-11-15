require File.expand_path('../../../spec_helper', __FILE__)

describe "Array#collect" do
  it "returns a copy of array with each element replaced by the value returned by block" do
    a = ['a', 'b', 'c', 'd']
    b = a.collect { |i| i + '!' }
    b.should == ['a!', 'b!', 'c!', 'd!']
    b.object_id.should_not == a.object_id
  end

  it "does not change self" do
    a = ['a', 'b', 'c', 'd']
    b = a.collect { |i| i + '!' }
    a.should == ['a', 'b', 'c', 'd']
  end

  it "returns the evaluated value of block if it broke in the block" do
    a = ['a', 'b', 'c', 'd']
    b = a.collect {|i|
      if i == 'c'
        break 0
      else
        i + '!'
      end
    }
    b.should == 0
  end
end

describe "Array#collect!" do
  it "replaces each element with the value returned by block" do
    a = [7, 9, 3, 5]
    a.collect! { |i| i - 1 }.should equal(a)
    a.should == [6, 8, 2, 4]
  end

  it "returns self" do
    a = [1, 2, 3, 4, 5]
    b = a.collect! {|i| i+1 }
    a.object_id.should == b.object_id
  end

  it "returns the evaluated value of block but its contents is partially modified, if it broke in the block" do
    a = ['a', 'b', 'c', 'd']
    b = a.collect! {|i|
      if i == 'c'
        break 0
      else
        i + '!'
      end
    }
    b.should == 0
    a.should == ['a!', 'b!', 'c', 'd']
  end
end
