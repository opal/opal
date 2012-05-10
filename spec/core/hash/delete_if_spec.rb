describe "Hash#delete_if" do
  it "yields two arguments: key and value" do
    all_args = []
    {1 => 2, 3 => 4}.delete_if { |*args| all_args << args }
    all_args.should == [[1, 2], [3, 4]]
  end

  it "removes every entry for which block is true and returns self" do
    h = {:a => 1, :b => 2, :c => 3, :d => 4}
    h.delete_if { |k,v| v % 2 == 1 }.should equal(h)
    h.should == {:b => 2, :d => 4}
  end
end