describe "Hash#member?" do
  it "returns true if the argument is a key" do
    h = {:a => 1, :b => 2, :c => 3, 4 => 0}
    h.member?(:a).should == true
    h.member?(:b).should == true
    h.member?(:B).should == false
    h.member?(2).should == false
    h.member?(4).should == true
    h.member?(42).should == false
  end

  it "returns true if the key's matching value was nil" do
    {:xyz => nil}.member?(:xyz).should == true
  end

  it "returns true if the key's matching value was false" do
    {:xyz => false}.member?(:xyz).should == true
  end

  it "returns true if the key is nil" do
    {nil => 'b'}.member?(nil).should == true
    {nil => nil}.member?(nil).should == true
  end
end