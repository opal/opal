describe "Kernel.loop" do
  it "calls block until it is terminated by a break" do
    i = 0
    loop do
      i += 1
      break if i == 10
    end

    i.should == 10
  end

  it "returns value passed to break" do
    loop do
      break 123
    end.should == 123
  end

  it "returns nil if no value passed to break" do
    loop do
      break
    end.should == nil
  end
end