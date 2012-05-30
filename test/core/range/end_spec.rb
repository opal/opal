describe "Range#end" do
  it "end returns the last element of self" do
    (-1..1).end.should == 1
    (0..1).end.should == 1
    ("A".."Q").end.should == "Q"
    ("A"..."Q").end.should == "Q"
    (0.5..2.4).end.should == 2.4
  end
end