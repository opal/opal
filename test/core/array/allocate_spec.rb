describe "Array.allocate" do
  `console.log("in here")`
  `console.log(this)`
  it "returns an instance of Array" do
    ary = Array.allocate
    ary.should be_kind_of(Array)
  end

  it "returns a fully-formed instance of Array" do
    ary = Array.allocate
    ary.size.should == 0
    ary << 1
    ary.should == [1]
  end
end