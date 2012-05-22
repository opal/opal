describe "Hash#keep_if" do
  it "yields two arguments: key and value" do
    all_args = []
    {1 => 2, 3 => 4}.keep_if { |*args| all_args << args }
    all_args.should == [[1, 2], [3, 4]]
  end

  it "keeps every entry for which block is true and returns self" do
    h = {:a => 1, :b => 2, :c => 3, :d => 4}
    h.keep_if { |k,v| v % 2 == 0 }.should equal(h)
    h.should == {:b => 2, :d => 4}
  end

  it "returns self even if unmodified" do
    h = {1 => 2, 3 => 4}
    h.keep_if { true }.should equal(h)
  end
end