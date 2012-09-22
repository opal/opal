describe "Array#to_a" do
  it "returns self" do
    a = [1, 2, 3]
    a.to_a.should == [1, 2, 3]
    a.should equal(a.to_a)
  end
end