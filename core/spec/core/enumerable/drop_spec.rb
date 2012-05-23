describe "Enumerable#drop" do
  before :each do
    @enum = EnumerableSpecs::Numerous.new(3, 2, 1, :go)
  end

  describe "passed a number n as an argument" do
    it "returns [] for empty enumerables" do
      EnumerableSpecs::Empty.new.drop(0).should == []
      EnumerableSpecs::Empty.new.drop(2).should == []
    end

    it "returns [] if dropping all" do
      @enum.drop(5).should == []
      EnumerableSpecs::Numerous.new(3, 2, 1, :go).drop(4).should == []
    end
  end
end