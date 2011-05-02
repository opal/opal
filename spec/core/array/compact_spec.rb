
describe "Array#compact" do
  it "returns a copy of array with all nil elements removed" do
    a = [1, 2, 4]
    a.compact.should == [1, 2, 4]
    a = [1, nil, 2, 4]
    a.compact.should == [1, 2, 4]
    a = [1, 2, 4, nil]
    a.compact.should == [1, 2, 4]
    a = [nil, 1, 2, 4]
    a.compact.should == [1, 2, 4]
  end
  
  it "does not return self" do
    a = [1, 2, 3]
    a.compact.object_id.should_not == a.object_id
  end
end

describe "Array#compact!" do
  it "removes all nil elements" do
    a = ['a', nil, 'b', false, 'c']
    a.compact!.object_id.should == a.object_id
    a.should == ['a', 'b', false, 'c']
    a = [nil, 'a', 'b', false, 'c']
    a.compact!.object_id.should == a.object_id
    a.should == ['a', 'b', false, 'c']
    a = ['a', 'b', false, 'c', nil]
    a.compact!.object_id.should == a.object_id
    a.should == ['a', 'b', false, 'c']
  end
  
  it "returns self if some nil elements are removed" do
    a = ['a', nil, 'b', false, 'c']
    a.compact!.object_id.should == a.object_id
  end
  
  it "returns nil if there are no nil elements to remove" do
    [1, 2, false, 3].compact!.should == nil
  end
end