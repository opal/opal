require File.expand_path('../../../spec_helper', __FILE__)

describe "Hash#assoc" do
  # before each
  $h = {:apple => :green, :orange => :orange, :grape => :green, :banana => :yellow}
  
  it "returns an Array if the argument is == to a key of the Hash" do
    $h.assoc(:apple).class.should == Array
  end
  
  it "returns a 2-element Array if the argument is == to a key of the Hash" do
    $h.assoc(:grape).size.should == 2
  end
  
  it "sets the first element of the Array to the located key" do
    $h.assoc(:banana).first.should == :banana
  end
  
  it "sets the last element of the array to the value of the located key" do
    $h.assoc(:banana).last.should == :yellow
  end
  
  it "uses #== to compare the argument to the keys" do
    $h[1.0] = :value
    1.should == 1.0
    $h.assoc(1).should == [1.0, :value]
  end
  
  it "returns nil if the argument is not a key of the Hash" do
    $h.assoc(:green).should == nil
  end
end
