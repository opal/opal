describe "Kernel#Array" do
  it "returns an Array containing the argument if it responds to neither #to_ary nor #to_a" do
    obj = mock('obj')
    Array(obj).should == [obj]
  end

  it "returns an empty Array when passed nil" do
    Array(nil).should == []
  end

  it "return new sorted Array if #sort" do
    a = [2, 7, 5, 9]
    b = a.sort

    b.should == [2, 5, 7, 9]
    b.object_id.should_not == a.object_id
  end


  it "return same sorted Array if #sort!" do
    a = [2, 7, 5, 9]
    b = a.sort!

    b.should == [2, 5, 7, 9]
    b.object_id.should == a.object_id
  end

  it "#sort and #sort! should support sorting functions" do
    ["one", "two", "three", "four"].sort {|a , b| a.length  <=> b.length }.should == ["one", "two", "four", "three"]
    [2, 7, 5, 9].sort! {|a , b| b <=> a }.should == [9, 7, 5, 2]
  end
end