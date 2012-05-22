describe "Hash#fetch" do
  it "returns the value for key" do
    {:a => 1, :b => -1}.fetch(:b).should == -1
  end

  it "raises and KeyError if key is not found" do
    lambda { Hash.new.fetch(:a) }.should raise_error(KeyError)
    lambda { Hash.new(5).fetch(:a) }.should raise_error(KeyError)
  end

  it "returns default if key is not found when passed a default" do
    Hash.new.fetch(:a, nil).should == nil
    Hash.new.fetch(:a, 'not here!').should == "not here!"
    {:a => nil}.fetch(:a, 'not here!').should == nil
  end

  it "returns value of block if key is not found when passed a block" do
    {}.fetch('a') { |k| k + '!' }.should == "a!"
  end

  it "gives precedence to the default block over the default argument when passed both" do
    {}.fetch(9, :foo) { |i| i * i }.should == 81
  end
end