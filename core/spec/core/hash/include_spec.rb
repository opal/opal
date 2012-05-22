describe "Hash#include?" do
  it "returns true if the argument is a key" do
    h = {:a => 1, :b => 2, :c => 3, 4 => 0}
    h.include?(:a).should == true
    h.include?(:b).should == true
    h.include?(:B).should == false
    h.include?(2).should == false
    h.include?(4).should == true
    h.include?(42).should == false
  end

  it "returns true if the key's matching value was nil" do
    {:xyz => nil}.include?(:xyz).should == true
  end

  it "returns true if the key's matching value was false" do
    {:xyz => false}.include?(:xyz).should == true
  end

  it "returns true if the key is nil" do
    {nil => 'b'}.include?(nil).should == true
    {nil => nil}.include?(nil).should == true
  end
end