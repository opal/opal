describe "Array#rassoc" do
  it "returns the first contained array whose second element it == object" do
    ary = [[1, "a", 0.5], [2, "b"], [3, "b"], [4, "c"], [], [5], [6, "d"]]
    ary.rassoc("a").should == [1, "a", 0.5]
    ary.rassoc("b").should == [2, "b"]
    ary.rassoc("d").should == [6, "d"]
    ary.rassoc("z").should == nil
  end
end