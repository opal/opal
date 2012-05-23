describe "Hash#each_pair" do
  it "yields the key and value of each pair to a block expecting |key, value|" do
    r = {}
    h = {:a => 1, :b => 2, :c => 3, :d => 5}
    h.each_pair { |k,v| r[k.to_s] = v.to_s }.should equal(h)
    r.should == {"a" => "1", "b" => "2", "c" => "3", "d" => "5"}
  end

  # FIXME: should be: h.each { |k,| ary << k }
  it "yields the key only to a block expecting |key,|" do
    ary = []
    h = {"a" => 1, "b" => 2, "c" => 3}
    h.each_pair { |k| ary << k }
    ary.should == ["a", "b", "c"]
  end

  it "uses the same order as keys() and values()" do
    h = {:a => 1, :b => 2, :c => 3, :d => 5}
    keys = []
    values = []

    h.each_pair do |k, v|
      keys << k
      values << v
    end

    keys.should == h.keys
    values.should == h.values
  end
end