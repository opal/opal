describe "Numeric#times" do
  it "returns self" do
    5.times {}.should == 5
    9.times {}.should == 9
    9.times { |n| n - 2 }.should == 9
  end

  it "yields each value from 0 to self - 1" do
    a = []
    9.times { |i| a << i }
    (-2).times { |i| a << i }
    a.should == [0, 1, 2, 3, 4, 5, 6, 7, 8]
  end

  it "skips the current iteration when encountering 'next'" do
    a = []
    3.times do |i|
      next if i == 1
      a << i
    end
    a.should == [0, 2]
  end

  it "skips all iterations when encountering 'break'" do
    a = []
    5.times do |i|
      break if i == 3
      a << i
    end
    a.should == [0, 1, 2]
  end

  it "skips all iterations when encountering break with an argument and returns that argument" do
    9.times { break 2 }.should == 2
  end
end