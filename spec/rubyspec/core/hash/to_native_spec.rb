describe "Hash#to_n" do
  it "should return a js object representing hash" do
    Hash.new({:a => 100, :b => 200}.to_n).should == {:a => 100, :b => 200}
  end
end
