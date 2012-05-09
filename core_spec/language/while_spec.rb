describe "The while expression" do
  it "runs while the expression is true" do
    i = 0
    while i < 3
      i += 1
    end
    i.should == 3
  end

  it "optionally takes a 'do' after the expression" do
    i = 0
    while i < 3 do
      i += 1
    end

    i.should == 3
  end

  it "allows body begin on the same line if do is used" do
    i = 0
    while i < 3 do i += 1
    end

    i.should == 3
  end

  it "executes code in containing variable scope" do
    i = 0
    while i != 1
      a = 123
      i = 1
    end

    a.should == 123
  end

  it "exectues code in containing variable scope with 'do'" do
    i = 0
    while i != 1 do
      a = 123
      i = 1
    end

    a.should == 123
  end

  it "returns nil is ended when condition became false" do
    i = 0
    while i < 3
      i += 1
    end.should == nil
  end

  it "does not evaluate the body if expression is empty" do
    a = []
    while ()
      a << :body_evaluated
    end
    a.should == []
  end

  it "stops running body if interrupted by break" do
    i = 0
    while i < 10
      i += 1
      break if i > 5
    end
    i.should == 6
  end

  it "returns value passed to break if interrupted by break" do
    while true
      break 123
    end.should == 123
  end

  it "returns nil if interrupted by break with no arguments" do
    while true
      break
    end.should == nil
  end

  it "skips to end of body with next" do
    a = []
    i = 0
    while (i+=1)<5
      next if i==3
      a << i
    end
    a.should == [1, 2, 4]
  end

  it "restarts the current iteration without reevaluating condition with redo" do
    a = []
    i = 0
    j = 0
    while (i+=1) <3
      a << i
      j+=1
      redo if j<3
    end
    a.should == [1, 1, 1, 2]
  end
end

describe "The while modifier" do
  it "runs preceding statement while the condition is true" do
    i = 0
    i += 1 while i < 3
    i.should == 3
  end

  it "evaluates condition before statement execution" do
    a = []
    i = 0
    a << i while (i+=1) < 3
    a.should == [1, 2]
  end

  it "does not run preceding statement if the condition is false" do
    i = 0
    i += 1 while false
    i.should == 0
  end

  it "does not run preceding statement if the condition is empty" do
    i = 0
    i += 1 while ()
    i.should == 0
  end

  it "returns nil if ended when condition became false" do
    i = 0
    (i += 1 while i<10).should == nil
  end

  it "returns value passed to break if interrupted by break" do
    (break 123 while true).should == 123
  end

  it "returns nil if interrupted by break with no arguments" do
    (break while true).should == nil
  end
end

describe "The while modifier with begin .. end block" do
  it "runs block while the expression is true" do
    i = 0
    begin
      i += 1
    end while i < 3

    i.should == 3
  end

  it "stops running block if interrupted by break" do
    i = 0
    begin
      i += 1
      break if i > 5
    end while i < 10

    i.should == 6
  end

  it "returns values passed to break if interrupted by break" do
    (begin; break 123; end while true).should == 123
  end

  it "returns nil if interrupted by break with no arguments" do
    (begin; break; end while true).should == nil
  end
end