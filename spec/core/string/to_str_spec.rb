describe "String#to_str" do
  it "returns self when self.class == String" do
    a = "a string"
    a.should equal(a.to_str)
  end
end