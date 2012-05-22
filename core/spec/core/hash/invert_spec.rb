describe "Hash#invert" do
  it "returns a new hash where keys are values and vice versa" do
    {1 => 'a', 2 => 'b', 3 => 'c'}.invert.should ==
      {'a' => 1, 'b' => 2, 'c' => 3}
  end

  it "handles collisions by overriding with the key coming later in keys()" do
    h = {:a => 1, :b => 1}
    override_key = h.keys.last
    h.invert[1].should == override_key
  end
end