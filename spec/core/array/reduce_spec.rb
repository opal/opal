describe "Array#reduce" do
  it "returns a single value and accepts the default value" do
    a = (1..7)
    b = a.reduce(1, &:+)
    b.should == 29
  end

  it "also responds to #inject and works with no default value" do
    a = (12..15)
    b = a.reduce { |sum, i| sum + i }
    b.should == 54
  end

  it "does not change self" do
    a = ['a', 'b', 'c', 'd']
    b = a.reduce('e') { |sum, i| [sum, i].join }
    a.should == ['a', 'b', 'c', 'd']
  end

  it "returns the evaluated value of block if it broke in the block" do
    a = ['a', 'b', 'c', 'd']
    b = a.reduce { |sum, i|
      if i == 'c'
        break 9
      else
        i + '!'
      end
    }
    b.should == 9
  end
end
