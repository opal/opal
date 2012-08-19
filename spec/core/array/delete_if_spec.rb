describe "Array#delete_if" do
  before do
    @a = [ "a", "b", "c" ]
  end

  it "removes each element for which block returns true" do
    @a = [ "a", "b", "c" ]
    @a.delete_if { |x| x >= "b" }
    @a.should == ["a"]
  end

  it "returns self" do
    @a.delete_if { true }.equal?(@a).should be_true
  end

  it "returns self when called on an Array emptied with #shift" do
    array = [1]
    array.shift
    array.delete_if { |x| true }.should equal(array)
  end
end