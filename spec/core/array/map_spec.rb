
describe "Array#map" do
  it "returns a copy of array with each element replaced by the value returned by block" do
    a = ['a', 'b', 'c', 'd']
    b = a.map { |i| i + '!' }
    b.should == ['a!', 'b!', 'c!', 'd!']
    
    # ignore
    # b.object_id.should_not == a.object_id
  end
  
  it "does not return subclass instance"
  
  it "does not change self" do
    a = ['a', 'b', 'c', 'd']
    b = a.map { |i| i + '!' }
    a.should == ['a', 'b', 'c', 'd']
  end
  
  it "returns the evaluated value of the block if it broke in the block" do
    a = ['a', 'b', 'c', 'd']
    b = a.map { |i| 
      if i == 'c'
        # break 0
      else
        i + '!'
      end
    }
    b.should == 0
  end
  
  it "returns an enumerator when no block given"
end
