describe "Range#begin" do
  it "returns the first element of self" do
    (-1..1).begin.should == -1
    (0..1).begin.should == 0
    ('Q'..'T').begin.should == 'Q'
    ('Q'...'T').begin.should == 'Q'
    (0.5..2.4).begin.should == 0.5
  end  
end