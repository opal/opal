describe "String#to_s" do
  it "returns self when self.class == String" do
    a = "a string"
    a.should equal(a.to_s)
  end

  it "returns a new instance of String when called on a subclass" do
    a = StringSpecs::MyString.new("a string")
    s = a.to_s
    s.should == "a string"
    s.should be_kind_of(String)
  end
end