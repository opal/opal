describe "Hash#merge" do
  it "returns a new hash by combining self with the contents of other" do
    h = {1 => :a, 2 => :b, 3 => :c}.merge(:a => 1, :c => 2)
    h.should == {:c => 2, 1 => :a, 2 => :b, :a => 1, 3 => :c}
  end

  it "sets any duplicate key to the value of the block if passed a block" do
    h1 = {:a => 2, :b => 1, :d => 5}
    h2 = {:a => -2, :b => 4, :c => -3}
    r = h1.merge(h2) { |k,x,y| nil }
    r.should == {:a => nil, :b => nil, :c => -3, :d => 5}

    r = h1.merge(h2) { |k,x,y| "#{k}:#{x+2*y}" }
    r.should == {:a => "a:-2", :b => "b:9", :c => -3, :d => 5}

    r = h1.merge(h1) { |k,x,y| :x }
    r.should == {:a => :x, :b => :x, :d => :x}
  end
end

describe "Hash#merge" do
  it "adds the entries from other, overwriting duplicate keys. Returns self" do
    h = {:_1 => 'a', :_2 => '3'}
    h.merge(:_1 => '9', :_9 => 2).should equal(h)
    h.should == {:_1 => "9", :_2 => "3", :_9 => 2}
  end

  it "sets any duplicate key to the value of block if passed a block" do
    h1 = {:a => 2, :b => -1}
    h2 = {:a => -2, :c => 1}
    h1.merge(h2) { |k,x,y| 3.14 }.should equal(h1)
    h1.should == {:c => 1, :b => -1, :a => 3.14}

    h1.merge(h1) { nil }
    h1.should == {:a => nil, :b => nil, :c => nil}
  end
end