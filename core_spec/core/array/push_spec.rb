describe "Array#push" do
  it "appends the arguments to the array" do
    a = [ "a", "b", "c" ]
    a.push("d", "e", "f").should equal(a)
    a.push().should == ["a", "b", "c", "d", "e", "f"]
    a.push(5)
    a.should == ["a", "b", "c", "d", "e", "f", 5]
  end

  it "isn't confused by previous shift" do
    a = [ "a", "b", "c" ]
    a.shift
    a.push("foo")
    a.should == ["b", "c", "foo"]
  end
end