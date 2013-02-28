require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../fixtures/classes', __FILE__)

describe "Array.[]" do
  pending "returns a new array populated with the given elements" do
    obj = Object.new
    Array.[](5, true, nil, 'a', "Ruby", obj).should == [5, true, nil, "a", "Ruby", obj]

    a = ArraySpecs::MyArray.[](5, true, nil, 'a', "Ruby", obj)
    a.should be_kind_of(ArraySpecs::MyArray)
    a.inspect.should == [5, true, nil, "a", "Ruby", obj].inspect
  end
end

describe "Array[]" do
  pending "is a synonym for .[]" do
    obj = Object.new
    Array[5, true, nil, 'a', "Ruby", obj].should == Array.[](5, true, nil, "a", "Ruby", obj)

    a = ArraySpecs::MyArray[5, true, nil, 'a', "Ruby", obj]
    a.should be_kind_of(ArraySpecs::MyArray)
    a.inspect.should == [5, true, nil, "a", "Ruby", obj].inspect
  end
end
