describe "Hash#update" do
  it "adds the entries from other, overwriting duplicate keys. Returns self" do
    h = {:_1 => 'a', :_2 => '3'}
    h.update(:_1 => '9', :_9 => 2).should equal(h)
    h.should == {:_1 => "9", :_2 => "3", :_9 => 2}
  end

  it "sets any duplicate key to the value of block if passed a block" do
    h1 = {:a => 2, :b => -1}
    h2 = {:a => -2, :c => 1}
    h1.update(h2) { |k,x,y| 3.14 }.should equal(h1)
    h1.should == {:c => 1, :b => -1, :a => 3.14}

    h1.update(h1) { nil }
    h1.should == {:a => nil, :b => nil, :c => nil}
  end
end