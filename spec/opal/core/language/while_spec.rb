describe "The while expression" do
  it "restarts the current iteration without reevaluating condition with redo" do
    a = []
    i = 0
    j = 0
    while (i+=1)<3
      a << i
      j+=1
      redo if j<3
      a << 5
    end
    a.should == [1, 1, 1, 5, 2, 5]
  end

  it "restarts the current iteration without evaluation the code below redo" do
    a = []
    i = 0
    while true
      i += 1
      a << i
      if i < 3
        redo
      else
        break
      end
      a << 5 # should never get here
    end
    a.should == [1, 2, 3]
  end

end
