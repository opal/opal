describe "String#to_s" do
  it "returns self when self.class == String" do
    a = "a string"
    a.should equal(a.to_s)
  end
end