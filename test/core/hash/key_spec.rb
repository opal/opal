describe "Hash#key?" do
  it "returns true if the argument is a key" do
    h = {:a => 1, :b => 2, :c => 3, 4 => 0}
    h.key?(:a).should == true
    h.key?(:b).should == true
    h.key?(:B).should == false
    h.key?(2).should == false
    h.key?(4).should == true
    h.key?(42).should == false
  end

  it "returns true if the key's matching value was nil" do
    {:xyz => nil}.key?(:xyz).should == true
  end

  it "returns true if the key's matching value was false" do
    {:xyz => false}.key?(:xyz).should == true
  end

  it "returns true if the key is nil" do
    {nil => 'b'}.key?(nil).should == true
    {nil => nil}.key?(nil).should == true
  end
end