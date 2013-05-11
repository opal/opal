describe "String#lines" do
  pending "should split on the default record separator and return enumerator if not block is given" do
    "first\nsecond\nthird".lines.class.should == Enumerator
    "first\nsecond\nthird".lines.entries.class.should == Array
    "first\nsecond\nthird".lines.entries.size.should == 3
    "first\nsecond\nthird".lines.entries.should == ["first\n", "second\n", "third"]
    "first\nsecond\nthird\n".lines.entries.should == ["first\n", "second\n", "third\n"]
  end
end
