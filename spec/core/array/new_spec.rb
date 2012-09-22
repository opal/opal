describe "Array.new" do
  it "returns an instance of Array" do
    Array.new.should be_kind_of(Array)
  end
end

describe "Array.new with no arguments" do
  it "returns an empty array" do
    Array.new.empty?.should be_true
  end
end

describe "Array.new with (array)" do
  it "returns an array initialized to the other array" do
    b = [4, 5, 6]
    Array.new(b).should == b
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

  it "yields the index of the element and sets the element to the value of the block" do
    Array.new(3) { |i| i.to_s }.should == ['0', '1', '2']
  end

  it "uses the block value instead of using the default value" do
    Array.new(3, :obj) { |i| i.to_s }.should == ['0', '1', '2']
  end
end