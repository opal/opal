
describe "Array#collect!" do
  it "replaces each element with the value returned by block" do
    a = [7, 9, 3, 5]
    a.collect! { |i| i - 1 }
    a.should == [6, 8, 2, 4]
  end
  
  it "returns self" do
    a = [1, 2, 3, 4, 5]
    b = a.collect! { |i| i + 1 }
    a.object_id.should == b.object_id
  end
  
  it "returns the evaluated value of block but its contents is partially modified, if it broke in the block" do
    a = ['a', 'b', 'c', 'd']
    b = a.collect! do |i|
      if i == 'c'
        # break 0
      else
        i + '!'
      end
    end
    b.should == 0
    a.should == ['a!', 'b!', 'c', 'd']
  end
end
