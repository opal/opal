describe "Numeric#times" do
  it "returns self" do
    expect(5.times {}).to eq(5)
    expect(9.times {}).to eq(9)
    expect(9.times { |n| n - 2 }).to eq(9)
  end

  it "yields each value from 0 to self - 1" do
    a = []
    9.times { |i| a << i }
    (-2).times { |i| a << i }
    expect(a).to eq([0, 1, 2, 3, 4, 5, 6, 7, 8])
  end

  it "skips the current iteration when encountering 'next'" do
    a = []
    3.times do |i|
      next if i == 1
      a << i
    end
    expect(a).to eq([0, 2])
  end

  it "skips all iterations when encountering 'break'" do
    a = []
    5.times do |i|
      break if i == 3
      a << i
    end
    expect(a).to eq([0, 1, 2])
  end

  it "skips all iterations when encountering break with an argument and returns that argument" do
    expect(9.times { break 2 }).to eq(2)
  end
end