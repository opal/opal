describe "Hash#[]=" do
  it "associates the key with the value and return the value" do
    h = {:a => 1}
    (h[:b] = 2).should == 2
    h.should == {:b => 2, :a => 1}
  end
end