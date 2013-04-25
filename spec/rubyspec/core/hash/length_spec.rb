describe "Hash#length" do
  it "returns the number of entries" do
    {:a => 1, :b => 'c'}.length.should == 2
    {:a => 1, :b => 2, :a => 2}.length.should == 2
    {:a => 1, :b => 1, :c => 1}.length.should == 3
    Hash.new.length.should == 0
    Hash.new(5).length.should == 0
    Hash.new { 5 }.length.should == 0
  end
end