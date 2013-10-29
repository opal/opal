# Just accepting reality of immutability

describe "String#freeze" do
  it "is always frozen" do
    s = "a string"
    s.frozen?.should be_true
    s.freeze
    s.frozen?.should be_true
  end

  it "returns self" do
    s = "a string"
    s.freeze.should equal(s)
  end
end
