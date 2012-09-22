describe "Hash.[]" do
  describe "passed zero arguments" do
    it "returns an empty hash" do
      Hash[].should == {}
    end
  end

  it "creates a Hash; values can be provided as the argument list" do
    Hash[:a, 1, :b, 2].should == { :a => 1, :b => 2 }
    Hash[].should == {}
    Hash[:a, 1, :b, {:c => 2}].should == {:a => 1, :b => {:c => 2}}
  end
end