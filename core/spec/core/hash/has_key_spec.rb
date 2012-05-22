describe "Hash#has_key?" do
  it "returns true if the argument is a key" do
    h = {:a => 1, :b => 2, :c => 3, 4 => 0}
    h.has_key?(:a).should == true
    h.has_key?(:b).should == true
    h.has_key?(:B).should == false
    h.has_key?(2).should == false
    h.has_key?(4).should == true
    h.has_key?(42).should == false
  end

  it "returns true if the key's matching value was nil" do
    {:xyz => nil}.has_key?(:xyz).should == true
  end

  it "returns true if the key's matching value was false" do
    {:xyz => false}.has_key?(:xyz).should == true
  end

  it "returns true if the key is nil" do
    {nil => 'b'}.has_key?(nil).should == true
    {nil => nil}.has_key?(nil).should == true
  end
end