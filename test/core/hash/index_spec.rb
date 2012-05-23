describe "Hash#index" do
  it "returns the corresponding key for value" do
    {2 => 'a', 1 => 'b'}.index('b').should == 1
  end

  it "returns nil if the value is not found" do
    {:a => -1, :b => 3.14, :c => 2.718}.index(1).should be_nil
  end

  it "doesn't return default value if the value isn't found" do
    Hash.new(5).index(5).should be_nil
  end
end