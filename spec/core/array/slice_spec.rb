describe "Array#slice!" do
  it "removes and return the element at index" do
    a = [1, 2, 3, 4]
    a.slice!(10).should == nil
    a.should == [1, 2, 3, 4]
    a.slice!(-10).should == nil
    a.should == [1, 2, 3, 4]
    a.slice!(2).should == 3
    a.should == [1, 2, 4]
    a.slice!(-1).should == 4
    a.should == [1, 2]
    a.slice!(1).should == 2
    a.should == [1]
    a.slice!(-1).should == 1
    a.should == []
    a.slice!(-1).should == nil
    a.should == []
    a.slice!(0).should == nil
    a.should == []
  end

  it "removes and returns length elements beginning at start" do
    a = [1, 2, 3, 4, 5, 6]
    a.slice!(2, 3).should == [3, 4, 5]
    a.should == [1, 2, 6]
    a.slice!(1, 1).should == [2]
    a.should == [1, 6]
    a.slice!(1, 0).should == []
    a.should == [1, 6]
    a.slice!(2, 0).should == []
    a.should == [1, 6]
    a.slice!(0, 4).should == [1, 6]
    a.should == []
    a.slice!(0, 4).should == []
    a.should == []
  end
end