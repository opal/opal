describe "Array#shuffle" do
  it "returns an array mixed up" do
    ary = [1, 2, 3, 4, 5]
    [1, 2, 3, 4, 5].shuffle.size.should eq(ary.size)
  end

  it "returns an array mixed up with UTF-8 characters" do
    ary = ["á", "é", "à", "ñÑ", "¥ØŁØ"]
    ["á", "é", "à", "ñÑ", "¥ØŁØ"].shuffle.size.should eq(ary.size)
  end
end
