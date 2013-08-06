require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../fixtures/classes', __FILE__)

describe "Array.new" do
  it "returns an instance of Array" do
    Array.new.should be_kind_of(Array)
  end

  it "returns an instance of a subclass" do
    ArraySpecs::MyArray.new(1, 2).should be_an_instance_of(ArraySpecs::MyArray)
  end

  it "raise an ArgumentError if passed 3 or more arguments" do
    lambda do
      Array.new(1, 'x', true)
    end.should raise_error(ArgumentError)
    lambda do
      [1, 2].send(:initialize, 1, 'x', true) {}
    end.should raise_error(ArgumentError)
  end
end

describe "Array.new with no arguments" do
  it "returns an empty array" do
    Array.new.should be_empty
  end

  it "does not use the given block" do
    lambda{ Array.new { raise } }.should_not raise_error
  end
end

describe "Array.new with (array)" do
  it "returns an array initialized to the other array" do
    b = [4, 5, 6]
    Array.new(b).should == b
  end

  it "does not use the given block" do
    lambda{ Array.new([1, 2]) { raise } }.should_not raise_error
  end

  it "calls #to_ary to convert the value to an array" do
    a = mock("array")
    def a.to_ary; [1,2]; end
    Array.new(a).should == [1, 2]
  end

  it "does not call #to_ary on instances of Array or subclasses of Array" do
    a = [1, 2]
    def a.to_ary; [1,2,3]; end
    Array.new(a).should == [1,2]
  end

  it "raises a TypeError if an Array type argument and a default object" do
    lambda { Array.new([1, 2], 1) }.should raise_error(TypeError)
  end
end

describe "Array.new with (size, object=nil)" do
  it "returns an array of size filled with object" do
    obj = [3]
    a = Array.new(2, obj)
    a.should == [obj, obj]
    a[0].should equal(obj)
    a[1].should equal(obj)
  end

  it "returns an array of size filled with nil when object is omitted" do
    Array.new(3).should == [nil, nil, nil]
  end

  it "raises an ArgumentError if size is negative" do
    lambda { Array.new(-1, :a) }.should raise_error(ArgumentError)
    lambda { Array.new(-1) }.should raise_error(ArgumentError)
  end

  platform_is :wordsize => 32 do
    it "raises an ArgumentError if size is too large" do
      max_size = ArraySpecs.max_32bit_size
      lambda { Array.new(max_size + 1) }.should raise_error(ArgumentError)
    end
  end

  platform_is :wordsize => 64 do
    it "raises an ArgumentError if size is too large" do
      max_size = ArraySpecs.max_64bit_size
      lambda { Array.new(max_size + 1) }.should raise_error(ArgumentError)
    end
  end

  it "calls #to_int to convert the size argument to an Integer when object is given" do
    obj = mock('1')
    def obj.to_int; 1; end
    Array.new(obj, :a).should == [:a]
  end

  it "calls #to_int to convert the size argument to an Integer when object is not given" do
    obj = mock('1')
    def obj.to_int; 1; end
    Array.new(obj).should == [nil]
  end

  it "raises a TypeError if the size argument is not an Integer type" do
    obj1 = mock('nonnumeric')
    def obj1.to_int; [1,2]; end
    lambda{ Array.new(obj1, :a) }.should raise_error(TypeError)

    obj2 = mock('nonnumeric')
    def obj2.to_int; "123"; end
    lambda{ Array.new(obj2, :a) }.should raise_error(TypeError)

    obj3 = mock('nonnumeric')
    def obj3.to_int; 1.2; end
    lambda{ Array.new(obj3, :a) }.should raise_error(TypeError)
  end

  it "yields the index of the element and sets the element to the value of the block" do
    Array.new(3) { |i| i.to_s }.should == ['0', '1', '2']
  end

  it "uses the block value instead of using the default value" do
    Array.new(3, :obj) { |i| i.to_s }.should == ['0', '1', '2']
  end

  it "returns the value passed to break" do
    Array.new(3) do |i|
      break if i == 2
      i.to_s
    end.should == nil

    Array.new(3) do |i|
      break 3 if i == 2
      i.to_s
    end.should == 3
  end
end
