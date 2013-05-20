describe "String#end_with?" do
  it "returns true only if ends with match" do
    s = "hello"
    s.end_with?('o').should be_true
    s.end_with?('llo').should be_true
    s.end_with?('ll').should be_false
  end

  it "returns true only if any ending match" do
    "hello".end_with?('x', 'y', 'llo', 'z').should be_true
  end

  it "should not return true if suffix length is 1 greater than string length" do
    "-".end_with?(' +').should be_false
  end
end
