describe "Array#==" do
  it "returns true if other is the same array" do
    a = [1]
    (a == a).should be_true
  end

  it "returns true if corresponding elements are #eql?" do
    ([] == []).should be_true
    ([1, 2, 3, 4] == [1, 2, 3, 4]).should be_true
  end

  it "returns false if other is shorter than self" do
    ([1, 2, 3, 4] == [1, 2, 3]).should be_false
  end

  it "returns false if other is longer than self" do
    ([1, 2, 3, 4] == [1, 2, 3, 4, 5]).should be_false
  end
end