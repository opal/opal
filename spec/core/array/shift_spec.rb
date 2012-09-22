describe "Array#shift" do
  it "removes and returns the first element" do
    a = [5, 1, 1, 5, 4]
    a.shift.should == 5
    a.should == [1, 1, 5, 4]
    a.shift.should == 1
    a.should == [1, 5, 4]
    a.shift.should == 1
    a.should == [5, 4]
    a.shift.should == 5
    a.should == [4]
    a.shift.should == 4
    a.should == []
  end

  it "returns nil whent the array is empty" do
    [].shift.should == nil
  end

  describe "passed a number n as an argument" do
    it "removes and returns an array with the first n element of the array" do
      a = [1, 2, 3, 4, 5, 6]

      a.shift(0).should == []
      a.should == [1, 2, 3, 4, 5, 6]

      a.shift(1).should == [1]
      a.should == [2, 3, 4, 5, 6]

      a.shift(2).should == [2, 3]
      a.should == [4, 5, 6]

      a.shift(3).should == [4, 5, 6]
      a.should == []
    end

    it "does not corrupt the array when shift without arguments is followed by shift with an argument" do
      a = [1, 2, 3, 4, 5]

      a.shift.should == 1
      a.shift(3).should == [2, 3, 4]
      a.should == [5]
    end

    it "returns whole elements if n exceeds size of the array" do
      a = [1, 2, 3, 4, 5]
      a.shift(6).should == [1, 2, 3, 4, 5]
      a.should == []
    end
  end
end