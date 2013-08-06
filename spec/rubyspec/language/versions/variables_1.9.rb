describe "Multiple assignments with splats" do
  it "* on the LHS has to be applied to any parameter" do
    # a, *b, c = 1, 2, 3
    a.should == 1
    b.should == [2]
    c.should == 3
  end
end
