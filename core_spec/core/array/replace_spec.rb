describe "Array#replace" do
  it "replaces the elements with elements from other array" do
    a = [1, 2, 3, 4, 5]
    b = ['a', 'b', 'c']
    a.replace(b).should equal(a)
    a.should == b
    a.should_not equal(b)

    a.replace([4] * 10)
    a.should == [4] * 10

    a.replace([])
    a.should == []
  end

  it "returns self" do
    ary = [1, 2, 3]
    other = [:a, :b, :c]
    ary.replace(other).should equal(ary)
  end

  it "does not make self dependent to the original array" do
    ary = [1, 2, 3]
    other = [:a, :b, :c]
    ary.replace(other)
    ary.should == [:a, :b, :c]
    ary << :d
    ary.should == [:a, :b, :c, :d]
    other.should == [:a, :b, :c]
  end
end