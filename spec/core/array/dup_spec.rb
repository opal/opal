describe "Array#dup" do
  it "produces a shallow copy where the references are directly copied" do
    a = [mock('1'), mock('2')]
    b = a.dup
    b.first.object_id.should == a.first.object_id
    b.last.object_id.should == a.last.object_id
  end

  it "creates a new array containing all the elements of the original" do
    a = [1, 2, 3, 4]
    b = a.dup
    b.should == a
    b.object_id.should_not == a.object_id
  end
end