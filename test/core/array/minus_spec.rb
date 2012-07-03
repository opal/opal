describe "Array#-" do
  it "subtracts two arrays" do
    ([ 1, 2, 3 ] - [ 3, 4, 5 ] ).should == [1, 2]
    ([ 1, 2, 3 ] - []).should == [1, 2, 3]
    ([] - [ 1, 2, 3 ]).should == []
    ([] - []).should == []
  end

  it "can subtracts an array from itself" do
    ary = [1, 2, 3]
    (ary - ary).should == []
  end
end
