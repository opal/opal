describe "Hash#shift" do
  it "removes a pair from hash and return it" do
    h = {:a => 1, :b => 2, "c" => 3, nil => 4, [] => 5}
    h2 = h.dup

    h.size.times do |i|
      r = h.shift
      # r.should be_kind_of(Array)
      # h2[r.first].should == r.last
      # h.size.should == h2.size - i - 1
    end

    h.should == {}
  end

  it "removes nil from an empty hash" do
    {}.shift.should == nil
  end
end