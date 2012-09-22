describe "Array#-" do
  it "creates an array minus any items from other array" do
    ([] - [1, 2, 4]).should == []
    ([1, 2, 4] - []).should == [1, 2, 4]
    ([1, 2, 3, 4, 5] - [1, 2, 4]).should == [3, 5]
  end

  it "removes multiple items on the lhs equal to one on the rhs" do
    ([1, 1, 2, 2, 3, 3, 4, 5] - [1, 2, 4]).should == [3, 3, 5]
  end

  it "is not destructive" do
    a = [1, 2, 3]
    a - []
    a.should == [1, 2, 3]
    a - [1]
    a.should == [1, 2, 3]
    a - [1, 2, 3]
    a.should == [1, 2, 3]
    a - [:a, :b, :c]
    a.should == [1, 2, 3]
  end
end