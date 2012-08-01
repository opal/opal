describe "Hash#to_native" do
  it "should return a js object representing hash" do
    Hash.from_native({:a => 100, :b => 200}.to_native).should == {:a => 100, :b => 200}
  end
end