
describe "Array.[]" do
  it "returns a new array populated with the given elements" do
    obj = Object.new
    Array.[](5, true, nil, 'a', "Ruby", obj).should == [5, true, nil, 'a', "Ruby", obj]
  end
end

describe "Array[]" do
  it "is a synonym for .[]" do
    obj = Object.new
    Array[5, true, nil, 'a', "Ruby", obj].should == [5, true, nil, 'a', "Ruby", obj]
  end
end
