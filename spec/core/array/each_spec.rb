describe "Array#each" do
  it "yields each element to the block" do
    a = []
    x = [1, 2, 3]
    x.each { |item| a << item }.should equal(x)
    a.should == [1, 2, 3]
  end

  it "returns an Enumerator if no block given" do
    [1, 2].each.should be_kind_of(Enumerator)
  end
end
