
describe "Hash literal" do
  it "{} should return an empty hash" do
    {}.size.should == 0
    {}.should == {}
  end
  
  it "{} should return a new hash populated with the given elements" do
    h = { :a => 'a', 'b' => 3, 44 => 2.3 }
    h.size.should == 3
    h.should == { :a => 'a', 'b' => 3, 44 => 2.3 }
  end
  
  it "treats empty expressions as nils" do
    h = {() => ()}
    h.keys.should == [nil]
    h.values.should == [nil]
    
    h = {() => :value}
    h.keys.should == [nil]
    h.values.should == [:value]
    h[nil].should == :value
    
    h = {:key => ()}
    h.keys.should == [:key]
    h.values.should == [nil]
    h[:key].should == nil
  end
end
