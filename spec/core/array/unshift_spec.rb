describe "Array#unshift" do
  it "prepends object to the original array" do
    a = [1, 2, 3]
    a.unshift("a").should equal(a)
    a.should == ['a', 1, 2, 3]
    a.unshift().should equal(a)
    a.should == ['a', 1, 2, 3]
    a.unshift(5, 4, 3)
    a.should == [5, 4, 3, 'a', 1, 2, 3]

    # shift all but one element
    a = [1, 2]
    a.shift
    a.unshift(3, 4)
    a.should == [3, 4, 2]

    # now shift all elements
    a.shift
    a.shift
    a.shift
    a.unshift(3, 4)
    a.should == [3, 4]
  end

  it "quietly ignores unshifting nothing" do
    [].unshift().should == []
    [].unshift(*[]).should == []
  end
end