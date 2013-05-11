describe "String#clone" do
  it "produces a copy of the original" do
    str = "a string"
    str_copy = str.dup
    str_copy.should == str
    str_copy.object_id.should_not == str.object_id
  end
end
