describe "Array#select" do
  it "passes an array item into a single default-block parameter" do
    [["ABC", "DEF"]].select do |x|
      expect(x).to eq(["ABC", "DEF"])
    end
  end

  it "splits an array item into a list of default block parameters" do
    [["ABC", "DEF"]].select do |x,y|
      expect(x).to eq("ABC")
      expect(y).to eq("DEF")
    end
  end
end
