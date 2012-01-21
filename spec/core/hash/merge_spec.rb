require File.expand_path('../../../spec_helper', __FILE__)
#require File.expand_path('../fixtures/classes', __FILE__)
#require File.expand_path('../shared/iteration', __FILE__)
require File.expand_path('../shared/update', __FILE__)

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
