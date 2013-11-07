describe "Array#select" do
  it "passes an array item into a single default-block parameter" do
    [["ABC", "DEF"]].select do |x|
      x.should == ["ABC", "DEF"]
    end
  end

  it "splits an array item into a list of default block parameters" do
    [["ABC", "DEF"]].select do |x,y|
      x.should == "ABC"
      y.should == "DEF"
    end
  end
end
