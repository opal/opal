describe "Array#to_ary" do
  it "returns self" do
    a = [1, 2, 3]
    a.should equal(a.to_ary)
  end
end