describe "String#%" do
  it "returns formatted string as same as Kernel#format" do
    ("%-5d" % 123).should == "123  "
  end

  it "can accept multiple arguments by passing them in an array" do
    ("%d %s" % [456, "foo"]).should == "456 foo"
  end
end
