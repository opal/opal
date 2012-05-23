module ArraySpecs
  class MyArray < Array
    def initialize(a, b)
      self << a << b
      ScratchPad.record :my_array_initialize
    end
  end
end

describe "Array.[]" do
  it "returns a new array populated with the given elements" do
    obj = Object.new
    Array.[](5, true, nil, 'a', "Ruby", obj).should == [5, true, nil, "a", "Ruby", obj]

    a = ArraySpecs::MyArray.[](5, true, nil, 'a', "Ruby", obj)
    a.should be_kind_of(ArraySpecs::MyArray)
    a.inspect.should == [5, true, nil, "a", "Ruby", obj].inspect
  end
end

describe "Array[]" do
  it "is a synonym for .[]" do
    obj = Object.new
    Array[5, true, nil, 'a', "Ruby", obj].should == [5, true, nil, "a", "Ruby", obj]

    a = ArraySpecs::MyArray[5, true, nil, 'a', "Ruby", obj]
    a.should be_kind_of(ArraySpecs::MyArray)
    a.inspect.should == [5, true, nil, "a", "Ruby", obj].inspect
  end
end