describe "Hash#replace" do
  it "replaces the contents of self with other" do
    h = {:a => 1, :b => 2}
    h.replace(:c => -1, :d => -2).should equal(h)
    h.should == {:c => -1, :d => -2}
  end
end