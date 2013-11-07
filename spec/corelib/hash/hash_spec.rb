describe Hash do
  describe "creating a hash with an inline native null value" do
    it "returns a hash with a nil value" do
      h = Hash.new(`{a: null}`)
      h[:a].should == nil
    end
  end
end
