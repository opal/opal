
describe "The || operator" do
  it "evaluates to true if any of its operands are true" do
    if false || true || nil
      x = true
    end
    x.should == true
  end
  
  it "evaluates to false if all of its operands are false" do
    if false || nil
      x = true
    end
    x.should == nil
  end
  
  it "is evaluated before assignment operators" do
    x = nil || true
    x.should == true
  end
  
  it "has a lower precedence than the && operator" do
    x = 1 || false && x = 2
    x.should == 1
  end
  
  it "treats empty expressions as nil" do
    (() || true).should == true
    (() || false).should == false
    (true || ()).should == true
    (false || ()).should == nil
    (() || ()).should == nil
  end
end
